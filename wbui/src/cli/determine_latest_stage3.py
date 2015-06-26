from __future__ import print_function

try:
    import urllib.request
except:
    import urllib

def setupOptions(parser):
    parser.add_option("-b", "--baseurl", dest="baseurl", help="Base URL which points gentoo mirror", default="http://ftp.kddilabs.jp/pub/Linux/distributions/gentoo/")
    parser.add_option("-a", "--arch", dest="arch", help="Specify architecture(amd64|x86)", default="amd64")


def run(options, args):
    def arch2arch(arch):
        return {"amd64":"amd64","x86":"i686"}[arch]

    url = "%s/releases/%s/autobuilds/latest-stage3-%s.txt" % (options.baseurl, options.arch, arch2arch(options.arch))
    f = urllib.request.urlopen(url) if hasattr(urllib, "request") else urllib.urlopen(url)
    stage3 = None
    line = f.readline()
    while line != None and line != b"":
        line = line.rstrip()
        if line != "" and not line.startswith(b'#') and arch2arch(options.arch) in line:
            stage3 = line.decode("utf-8")
            break
        line = f.readline()
    f.close()
    if stage3 == None: raise Exception("stage3 not found")
    print("%s/releases/%s/autobuilds/%s" % (options.baseurl, options.arch, stage3))
