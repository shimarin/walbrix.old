import argparse,json,sys
import lxml.etree

def run(catalog):
    root = lxml.etree.Element("virtual-appliance", uuid=catalog["uuid"])
    version = lxml.etree.Element("version")
    version.text = catalog["version"]
    root.append(version)
    if "instruction" in catalog:
        if isinstance(catalog["instruction"], dict):
            if "ja" in catalog["instruction"]:
                instruction = lxml.etree.Element("instruction")
                instruction.attrib["{http://www.w3.org/XML/1998/namespace}lang"] = "ja"
                instruction.text = catalog["instruction"]["ja"]
                root.append(instruction)
                del catalog["instruction"]["ja"]
            for lang, text in catalog["instruction"].iteritems():
                instruction = lxml.etree.Element("instruction")
                instruction.attrib["{http://www.w3.org/XML/1998/namespace}lang"] = lang
                instruction.text = text
                root.append(instruction)
        else:
            instruction = lxml.etree.Element("instruction")
            instruction.text = catalog["instruction"]
            root.append(instruction)
    return lxml.etree.ElementTree(root)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("catalog", type=str, help="catalog file")
    args = parser.parse_args()
    etree = run(json.load(open(args.catalog)))
    etree.write(sys.stdout, pretty_print=True, encoding='UTF-8', xml_declaration=True)

