import subprocess,os,re

if os.getuid() != 0: raise Exception("You must be a root user.")

distfiles = "/usr/portage/distfiles"
keep_files = set()

subprocess.check_call(["wget","--spider","--no-remove-listing","ftp://ftp.kddilabs.jp/pub/Linux/distributions/gentoo/distfiles/"])
try:
    for line in open(".listing").readlines():
        line = re.split(r'\s+',line, 8)
        if len(line) < 9: continue
        keep_files.add(line[8].strip())
    for present_file in os.listdir(distfiles):
        if present_file not in keep_files:
            print "Removing %s..." % present_file
            os.unlink(os.path.join(distfiles, present_file))
finally:
    os.unlink(".listing")


