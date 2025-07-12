#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET

def merge_fonts_customization(files):
    """Merge multiple fonts_customization.xml files into one."""

    # Create root element
    root = ET.Element("fonts-modification")
    root.set("version", "1")

    # Simply append all children from all files
    for file in files:
        tree = ET.parse(file)
        file_root = tree.getroot()

        for element in file_root:
            root.append(element)

    # Convert to string with proper formatting
    ET.indent(root)
    return ET.tostring(root, encoding='unicode', xml_declaration=True)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: merge_fonts.py <input_files...>")
        sys.exit(1)

    result = merge_fonts_customization(sys.argv[1:])
    print(result)
