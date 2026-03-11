#!/usr/bin/env python3
#
# Copyright (C) 2026 The halogenOS Project
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

"""Injects the build date into target-files build.prop files.

branding.mk uses a placeholder date (00000000-000000) to keep builds
reproducible.  This script replaces the placeholder with the actual
date right before signing, so partition images contain the real
timestamp without the build system depending on it.

This follows the same pattern as sign_target_files_apks' RewriteProps:
iterate build.prop files in the target-files tree, rewrite matching
key=value lines, and write them back.

Usage:
  inject_build_date.py <target-files-dir-or-zip> [--timestamp EPOCH]
"""

import argparse
import datetime
import os
import sys
import time
import zipfile

DATE_PLACEHOLDER = "00000000-000000"
BUILD_NUMBER_PLACEHOLDER = "/0000:"


def rewrite_props(data, build_date, build_number):
  """Rewrites date placeholders in build.prop content."""
  output = []
  changed = False
  for line in data.split("\n"):
    original = line
    if DATE_PLACEHOLDER in line:
      line = line.replace(DATE_PLACEHOLDER, build_date)
    if BUILD_NUMBER_PLACEHOLDER in line:
      line = line.replace(BUILD_NUMBER_PLACEHOLDER, "/%s:" % build_number)
    if line != original:
      changed = True
    output.append(line)
  return "\n".join(output), changed


def is_build_prop(filename):
  return (filename.endswith("build.prop") or
          filename.endswith("/default.prop") or
          filename.endswith("/prop.default"))


def process_directory(target_dir, build_date, build_number):
  for root, _, files in os.walk(target_dir):
    for f in files:
      if not is_build_prop(f):
        continue
      path = os.path.join(root, f)
      with open(path, "r") as fp:
        data = fp.read()
      new_data, changed = rewrite_props(data, build_date, build_number)
      if changed:
        rel = os.path.relpath(path, target_dir)
        print("  Injected build date into: %s" % rel)
        with open(path, "w") as fp:
          fp.write(new_data)


def process_zip(zip_path, build_date, build_number):
  import tempfile
  import shutil

  tmp = tempfile.mkdtemp(prefix="inject_date_")
  try:
    with zipfile.ZipFile(zip_path, "r", allowZip64=True) as zf:
      zf.extractall(tmp)
    process_directory(tmp, build_date, build_number)
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED,
                         allowZip64=True) as zf:
      for root, _, files in os.walk(tmp):
        for f in files:
          full = os.path.join(root, f)
          arcname = os.path.relpath(full, tmp)
          zf.write(full, arcname)
  finally:
    shutil.rmtree(tmp)


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("target", help="target-files directory or zip")
  parser.add_argument("--timestamp", type=int, default=None,
                      help="UTC epoch timestamp (default: now)")
  args = parser.parse_args()

  ts = args.timestamp if args.timestamp is not None else int(time.time())
  dt = datetime.datetime.fromtimestamp(ts, datetime.UTC)
  build_date = dt.strftime("%Y%m%d-%H%M%S")
  build_number = dt.strftime("%H%M")

  print("Injecting build date: %s" % build_date)

  if os.path.isdir(args.target):
    process_directory(args.target, build_date, build_number)
  elif zipfile.is_zipfile(args.target):
    process_zip(args.target, build_date, build_number)
  else:
    print("Error: %s is neither a directory nor a zip file" % args.target,
          file=sys.stderr)
    return 1

  return 0


if __name__ == "__main__":
  sys.exit(main())
