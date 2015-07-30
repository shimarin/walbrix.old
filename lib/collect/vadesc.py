import os,json
import catalog2vadesc

def apply(context, args):
    if len(args) != 0: raise Exception("$vadesc directive doesn't take args")
    catalog_file = "catalog/%s-%s-%s.json" % (context.get_variable("ARTIFACT"), context.get_variable("ARCH"), context.get_variable("REGION"))
    catalog = json.load(open(catalog_file))
    etree = catalog2vadesc.run(catalog)
    etc = os.path.join(context.destination, "etc")
    if not os.path.isdir(etc): os.mkdir(etc)
    with open("%s/etc/wb-va.xml" % context.destination, "w") as f:
        etree.write(f, pretty_print=True, encoding='UTF-8', xml_declaration=True)

