#!/usr/bin/python3
import os,subprocess,glob,shutil
import argparse,platform
import xml.etree.ElementTree as ET,gzip
import requests

BASE_URL="http://ftp.iij.ad.jp/pub/linux/centos/8-stream/BaseOS/x86_64/os/"
INSTALL=["yum", "passwd", "vim-minimal", "strace", "less", "kernel", "tar", "openssh-server", "openssh-clients", "avahi", "NetworkManager"]
OPTIONAL=["dhclient"]

packages = {}
providers = {}
rpms = set()

def install(package):
    rpm = package["location"]
    if rpm in rpms: return
    rpms.add(rpm)
    for require in package["requires"]:
        if require not in providers:
            print("A provider for %s not found." % require)
            continue
        #else
        install(providers[require][0])

def main(base, arch, keep_rpm, target_dir):
    if not base.endswith('/'):
        base += '/'
    
    if not os.path.isdir(target_dir):
        raise Exception("%s is not a directory." % target_dir)

    rpm_dir = os.path.join(target_dir, ".rpms")

    os.makedirs(rpm_dir, exist_ok=True)

    repmod_xml = "%srepodata/repomd.xml" % (base)
    print(repmod_xml)
    r = requests.get(repmod_xml)
    if r.status_code != 200: exit(1)
    #else

    primary = ET.fromstring(r.content).find("{http://linux.duke.edu/metadata/repo}data[@type='primary']/{http://linux.duke.edu/metadata/repo}location").attrib["href"]

    r = requests.get("%s/%s" % (base,primary))
    if r.status_code != 200: exit(1)

    for package in ET.fromstring(gzip.decompress(r.content)).findall("{http://linux.duke.edu/metadata/common}package[@type='rpm']"):
        pkg_arch = package.find("{http://linux.duke.edu/metadata/common}arch").text
        if pkg_arch not in [arch, "noarch"]: continue
        p = {
            "name": package.find("{http://linux.duke.edu/metadata/common}name").text,
            "arch": pkg_arch,
            "location": package.find("{http://linux.duke.edu/metadata/common}location").attrib["href"],
            "requires": []
        }

        for require in package.findall("{http://linux.duke.edu/metadata/common}format/{http://linux.duke.edu/metadata/rpm}requires/{http://linux.duke.edu/metadata/rpm}entry"):
            p["requires"].append(require.attrib["name"])

        for provide in package.findall("{http://linux.duke.edu/metadata/common}format/{http://linux.duke.edu/metadata/rpm}provides/{http://linux.duke.edu/metadata/rpm}entry"):
            name = provide.attrib["name"]
            if name in providers:
                providers[name].append(p)
            else:
                providers[name] = [p]
        
        for file in package.findall("{http://linux.duke.edu/metadata/common}format/{http://linux.duke.edu/metadata/common}file"):
            name = file.text
            if name in providers:
                providers[name].append(p)
            else:
                providers[name] = [p]

        packages[p["name"]] = p
        
    print("%d packages." % len(packages))

    for package in INSTALL:
        install(packages[package])
    
    for package in OPTIONAL:
        if package in packages: install(packages[package])

    for rpm in rpms:
        subprocess.run(["wget", "-N", "--directory-prefix=%s" % rpm_dir, "%s/%s" % (base, rpm)], check=True)

    proc = os.path.join(target_dir, "proc")
    sys = os.path.join(target_dir, "sys")
    dev = os.path.join(target_dir, "dev")
    run = os.path.join(target_dir, "run")
    etc = os.path.join(target_dir, "etc")

    os.makedirs(proc, exist_ok=True)
    os.makedirs(sys, exist_ok=True)
    os.makedirs(dev, exist_ok=True)
    os.makedirs(run, exist_ok=True)
    os.makedirs(etc, exist_ok=True)

    with open(os.path.join(etc, "fstab"), "w") as f:
        pass

    subprocess.run(["mount", "-t", "proc", "proc", proc], check=True)
    try:
        subprocess.run(["mount", "-t", "sysfs", "sysfs", sys], check=True)
        try:
            subprocess.run(["mount", "-o", "bind", "/dev", dev], check=True)
            try:
                subprocess.run(["mount", "-t", "tmpfs", "tmpfs", run], check=True)
                try:
                    subprocess.run(["rpm", "-Uvh", "--root=%s" % os.path.abspath(target_dir)] + glob.glob(os.path.join(rpm_dir, "*")))
                finally:
                    subprocess.run(["umount", run])
            finally:
                subprocess.run(["umount", dev])
        finally:
            subprocess.run(["umount", sys])
    finally:
        subprocess.run(["umount", proc])
    
    if not keep_rpm:
        shutil.rmtree(rpm_dir)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=BASE_URL, help="Base URL contains repodata/ subdirectory")
    parser.add_argument("--arch", default=platform.machine())
    parser.add_argument("--keep-rpm", action="store_true")
    parser.add_argument("target_dir")
    args = parser.parse_args()
    main(args.base, args.arch, args.keep_rpm, args.target_dir)
    print("Done.")
