#!/usr/bin/env python
# Copyright (C) 2012-2013, The CyanogenMod Project
#           (C) 2017-2018,2020-2021, The LineageOS Project
# Copyright (C) 2022 The halogenOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

import base64
import json
import netrc
import os
import re
import sys
try:
  # For python3
  import urllib.error
  import urllib.parse
  import urllib.request
except ImportError:
  # For python2
  import imp
  import urllib2
  import urlparse
  urllib = imp.new_module('urllib')
  urllib.error = urllib2
  urllib.parse = urlparse
  urllib.request = urllib2

from xml.etree import ElementTree

org_git = "git.halogenos.org"
org_manifest = "XOS"
org_display = "halogenOS"
custom_default_revision = "XOS-15.0"
custom_default_fallback_revisions = ["XOS-13.0"]
product = sys.argv[1]

if len(sys.argv) > 2:
    depsonly = sys.argv[2]
else:
    depsonly = None

try:
    device = product[product.index("_") + 1:]
except:
    device = product

if device.find("sdk_phone") == 0:
    print("SDK Phone, skipping roomservice")
    sys.exit()

if not depsonly:
    print("Device %s not found. Attempting to retrieve device repository." % device)

repositories = []

if not depsonly:
    req = urllib.request.Request(
        "https://{2}/api/v4/groups/{1}/projects?"
        "search={0}".format(device, org_display, org_git))
    try:
        repositories = json.loads(urllib.request.urlopen(req).read().decode())
    except urllib.error.URLError:
        print("Failed to search")
        sys.exit(1)
    except ValueError:
        print("Failed to parse return data")
        sys.exit(1)

local_manifests = r'.repo/local_manifests'
if not os.path.exists(local_manifests): os.makedirs(local_manifests)

def exists_in_tree(lm, path):
    for child in lm.getchildren():
        if child.attrib['path'] == path:
            return True
    return False

# in-place prettyprint formatter
def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def get_manifest_path():
    '''Find the current manifest path
    In old versions of repo this is at .repo/manifest.xml
    In new versions, .repo/manifest.xml includes an include
    to some arbitrary file in .repo/manifests'''

    m = ElementTree.parse(".repo/manifest.xml")
    try:
        m.findall('default')[0]
        return '.repo/manifest.xml'
    except IndexError:
        return ".repo/manifests/{}".format(m.find("include").get("name"))

def get_from_manifest(devicename):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if re.search("(android_|platform_)?device_.*_%s$" % device, localpath.get("name")):
            return localpath.get("path")

    return None

def is_in_manifest(projectpath):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # Search in main manifest, too
    try:
        lm = ElementTree.parse(get_manifest_path())
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # ... and don't forget the snippets
    try:
        lm = ElementTree.parse(".repo/manifests/snippets/git-srvs.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    try:
        lm = ElementTree.parse(".repo/manifests/snippets/XOS.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    return False

def add_to_manifest(repositories):
    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for repository in repositories:
        repo_name = repository['repository']
        repo_target = repository['target_path']

        if 'branch' in repository:
            repo_revision=repository['branch']
        else:
            repo_revision=custom_default_revision

        if 'remote' in repository:
            repo_remote=repository['remote']
        elif "/" not in repo_name:
            repo_remote=org_manifest
        elif "/" in repo_name:
            repo_remote="github"

        print('Checking if %s is fetched from %s' % (repo_target, repo_name))
        if is_in_manifest(repo_target):
            print('%s already fetched to %s' % (repo_name, repo_target))
            continue

        print('Adding dependency:')
        print('Repository: %s' % repo_name)
        print('Revision: %s' % repo_revision)
        print('Remote: %s' % repo_remote)
        print('Target: %s' % repo_target)
        print('Origin: %s' % repo_path)
        print("")
        project = ElementTree.Element("project", attrib = {
            "path": repo_target,
            "remote": repo_remote,
            "name": repo_name,
        })
        if repo_revision is not None:
            project.set('revision', repo_revision)
        else:
            print("Using revision %s for %s" %
                  (custom_default_revision, repo_name))
            project.set('revision', custom_default_revision)

        if 'clone_depth' in repository:
            project.set('clone-depth', repository['clone_depth'])

        lm.append(project)

    indent(lm, 0)
    raw_xml = ElementTree.tostring(lm).decode()
    raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + raw_xml

    f = open('.repo/local_manifests/roomservice.xml', 'w')
    f.write(raw_xml)
    f.close()

def fetch_dependencies(repo_path):
    print('Looking for dependencies in %s' % repo_path)

    syncable_repos = []
    verify_repos = []
    is_lineage = False
    is_crdroid = False
    is_arrow = False
    is_yaap = False
    is_pixys = False

    dependencies_path = repo_path + '/aosp.dependencies'
    if not os.path.exists(dependencies_path):
        # LineageOS dependencies
        dependencies_path = repo_path + '/lineage.dependencies'
        if not os.path.exists(dependencies_path):
            # crdroidandroid dependencies
            dependencies_path = repo_path + "/crdroid.dependencies"
            if not os.path.exists(dependencies_path):
                # ArrowOS-Devices dependencies
                dependencies_path = repo_path + "/arrow.dependencies"
                if not os.path.exists(dependencies_path):
                    # YAAP dependencies
                    dependencies_path = repo_path + "/yaap.dependencies"
                    if not os.path.exists(dependencies_path):
                        # Pixys dependencies
                        dependencies_path = repo_path + "/pixys.dependencies"
                        if not os.path.exists(dependencies_path):
                            print("No additional dependencies for %s" % repo_path)
                            return
                        else:
                            is_pixys = True
                    else:
                        is_yaap = True
                else:
                    is_arrow = True
            else:
                is_crdroid = True
        else:
            is_lineage = True

    dependencies_file = open(dependencies_path, 'r')
    dependencies = json.loads(dependencies_file.read())
    fetch_list = []

    for dependency in dependencies:
        if not is_in_manifest(dependency['target_path']):
            if is_crdroid and re.match(r"^crdroidandroid/.+$", dependency['repository']):
                print("Detected crdroidandroid repository %s, converting" % dependency['repository'])
                dependency['repository'] = dependency['repository'].removeprefix("crdroidandroid/")
                groups = re.match(r"^proprietary_vendor_(.+)", dependency['repository'])
                if groups is not None:
                    dependency['repository'] = "android_vendor_%s" % (groups.group(1))
                groups = re.match(r"^(android_vendor_)([A-Za-z0-9]+?)-([A-Za-z0-9-]+)$", dependency['repository'])
                if groups is not None:
                    dependency['repository'] = "%s%s_%s" % (groups.group(1), groups.group(2), groups.group(3))

            elif is_lineage and re.match(r"^LineageOS/.+$", dependency['repository']):
                print("Detected LineageOS repository %s, converting" % dependency['repository'])
                dependency['repository'] = dependency['repository'].removeprefix("LineageOS/")

            elif is_arrow:
                print("Detected ArrowOS repository %s, converting" % dependency["repository"])
                dependency['repository'] = "android_%" % (dependency['repository'])

            elif is_pixys:
                print("Detected PixysOS repository %s, converting" % dependency["repository"])
                dependency['repository'] = "android_%" % (dependency['repository'])

            elif is_yaap:
                print("Detected YAAP repository %s, converting" % dependency['repository'])
                dependency['repository'] = f"android_{dependency['repository']}"

            print("Dependency repository: %s" % dependency['repository'])
            fetch_list.append(dependency)
            syncable_repos.append(dependency['target_path'])
            if 'branch' not in dependency:
                dependency['branch'] = get_default_or_fallback_revision(dependency['repository'])
        verify_repos.append(dependency['target_path'])

        if not os.path.isdir(dependency['target_path']):
            syncable_repos.append(dependency['target_path'])

    dependencies_file.close()

    if len(fetch_list) > 0:
        print('Adding dependencies to manifest')
        add_to_manifest(fetch_list)

    if len(syncable_repos) > 0:
        print('Syncing dependencies')
        os.system('repo sync --force-sync --no-clone-bundle --no-tags %s' % ' '.join(syncable_repos))

    for deprepo in verify_repos:
        fetch_dependencies(deprepo)

def has_branch(branches, revision):
    return revision in [branch['name'] for branch in branches]

def get_latest_branch(branches, revision):
    branch_names = [branch['name'] for branch in branches]

    # Define a custom sorting function to extract the version number
    def extract_version(branch_name):
        # Assuming the format is "XOS-X.X.X"
        match = re.match(r'^([A-Z]+-\d+\.\d+(\.\d+)?)$', branch_name)
        if match:
            return list(map(int, match.group(1).split('-')[1].split('.')))
        return []

    # Filter branches that match the provided revision and have the correct format
    matching_branches = [branch for branch in branch_names if branch.startswith(revision) and extract_version(branch)]

    if matching_branches:
        # Find the latest branch based on version number
        latest_branch = max(matching_branches, key=extract_version)
    else:
        # If there are no matching branches with a specific version, use the less specific branch
        # For example, if "XOS-15.0" is present but not "XOS-15.0.1"
        less_specific_revision = revision.rsplit('-', 1)[0]
        matching_branches = [branch for branch in branch_names if branch.startswith(less_specific_revision) and extract_version(branch)]
        if matching_branches:
            latest_branch = max(matching_branches, key=extract_version)
        else:
            latest_branch = None  # No matching branches found

    return latest_branch


def get_default_or_fallback_revision(repo_name):
    default_revision = custom_default_revision
    print("Default revision: %s" % default_revision)
    print("Checking branch info for %s" % repo_name)

    req = urllib.request.Request(
        "https://{1}/api/v4/projects/{0}/repository/branches".format(
            urllib.parse.quote_plus("%s/%s" % (org_display, repo_name)), org_git))
    result = json.loads(urllib.request.urlopen(req).read().decode())

    if has_branch(result, default_revision):
        return get_latest_branch(result, default_revision)

    fallbacks = custom_default_fallback_revisions

    for fallback in fallbacks:
        if has_branch(result, fallback):
            latest_fallback = get_latest_branch(result, fallback)
            print("Using fallback branch: %s" % latest_fallback)
            return latest_fallback

    print("Default revision %s not found in %s. Bailing." % (default_revision, repo_name))
    print("Branches found:")
    for branch in [branch['name'] for branch in result]:
        print(branch)
    sys.exit()

if depsonly:
    repo_path = get_from_manifest(device)
    if repo_path:
        fetch_dependencies(repo_path)
    else:
        print("Trying dependencies-only mode on a non-existing device tree?")

    sys.exit()

else:
    for repository in repositories:
        repo_name = repository['name']
        if re.match(r"^(android_|platform_)?device_[^_]*_" + device + "$", repo_name):
            print("Found repository: %s" % repository['name'])

            manufacturer = repo_name[repo_name.index("device_")+7:-(len(device)+1)]
            repo_path = "device/%s/%s" % (manufacturer, device)
            revision = get_default_or_fallback_revision(repo_name)

            device_repository = {'repository':repo_name,'target_path':repo_path,'branch':revision}
            add_to_manifest([device_repository])

            print("Syncing repository to retrieve project.")
            os.system('repo sync --force-sync --no-clone-bundle --no-tags %s' % repo_path)
            print("Repository synced!")

            fetch_dependencies(repo_path)
            print("Done")
            sys.exit()

print("Repository for %s not found in the repository list. If this is in error, you may need to manually add it to your local_manifests/roomservice.xml" % device)
