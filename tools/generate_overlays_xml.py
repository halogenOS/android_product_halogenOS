#!/usr/bin/env python3
import os
import sys

from xml.etree import ElementTree

overlays_xml_relative = "xml/overlays.xml"

def run(resdir: str):
    target_xml = os.path.join(resdir, overlays_xml_relative)
    if os.path.exists(target_xml):
        overlays_xml = ElementTree.parse(target_xml)
        overlays_root = overlays_xml.getroot()
        overlays_root.clear()
    else:
        overlays_root = ElementTree.Element("overlay")
    overlays_root.set("xmlns:android", "http://schemas.android.com/apk/res/android")

    for root, _, files in os.walk(resdir):
        for name in files:
            realpath=os.path.realpath(os.path.join(root, name))
            relative_file=os.path.relpath(realpath, start=resdir)
            if relative_file == overlays_xml_relative:
                continue

            generate_for(realpath, overlays_root)

    ElementTree.indent(overlays_root)
    ElementTree.ElementTree(overlays_root).write(
        target_xml,
        xml_declaration=True,
        encoding="utf-8"
    )

def generate_for(res_file: str, overlays_root: ElementTree.ElementTree):
    res_xml = ElementTree.parse(res_file)
    resources = res_xml.getroot()
    for resource in resources:
        should_map = resource.get("mapped")
        if should_map is not None and should_map != "true":
            continue
        res_type = resource.tag
        if resource.get("type"):
            res_type = resource.get("type")

        res_name = resource.get("name")
        item = ElementTree.Element("item", attrib={
            "target": f"{res_type}/{res_name}",
            "value": f"@{res_type}/{res_name}",
        })
        overlays_root.append(item)

if __name__ == "__main__":
    if len(sys.argv) <= 1:
        print("missing res argument")
    run(sys.argv[1])