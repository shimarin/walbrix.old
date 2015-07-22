import argparse,re,os,json
import create_install_disk

DEFAULT_SYSTEM_IMAGE="/.overlay/boot/walbrix"
VAR_MATCH = re.compile(r'^set (.+?)=(.+)$')

def read(image=DEFAULT_SYSTEM_IMAGE):
    vars = {}
    with create_install_disk.tempmount(image, "loop,ro","squashfs") as tmpdir:
        with open("%s/walbrix.cfg" % tmpdir) as f:
            while True:
                line = f.readline()
                if not line: break
                match = VAR_MATCH.match(line.strip())
                if not match: continue
                key, value = match.groups()
                vars[key] = value
    return vars

def run(image=DEFAULT_SYSTEM_IMAGE):
    if not os.path.isfile(image): raise Exception("%s not found" % image)
    print read(image)["WALBRIX_VERSION"]

def run_async(image=DEFAULT_SYSTEM_IMAGE):
    try:
        vars = read(image)
        rst = {"version":vars["WALBRIX_VERSION"]}
        if "WALBRIX_BUILD_ID" in vars: rst["build_id"] = vars["WALBRIX_BUILD_ID"]
        print "R " + json.dumps(rst)
    except Exception, e:
        print e

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=str, default=DEFAULT_SYSTEM_IMAGE, help="System image file to install")
    parser.add_argument("--async", action="store_true", help="Act as an API")
    args = parser.parse_args()
    run_async(args.image) if args.async else run(args.image)

