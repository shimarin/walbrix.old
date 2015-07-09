import argparse,struct,urllib2

def read_latest_file(latest_file_url):
    for line in urllib2.urlopen(latest_file_url).readlines():
        if line == "" or line.startswith('#'): continue
        return line.split(' ', 1)[0]
    raise Exception("No latest stage3 archive is mentioned in %s" % latest_file_url)
    
def run(arch, baseurl):
    if arch == "i686":
        autobuilds_base = baseurl + "/releases/x86/autobuilds"
        latest_file = autobuilds_base + "/latest-stage3-i686.txt"
    elif arch == "x86_64":
        autobuilds_base = baseurl + "/releases/amd64/autobuilds"
        latest_file = autobuilds_base + "/latest-stage3-amd64.txt"

    return "%s/%s" % (autobuilds_base, read_latest_file(latest_file))

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--baseurl", help="Base URL which points gentoo mirror", default="http://ftp.kddilabs.jp/pub/Linux/distributions/gentoo")
    parser.add_argument("arch", type=str, nargs='?', default="x86_64", help="architecture")
    args = parser.parse_args()
    print run(args.arch, args.baseurl)

