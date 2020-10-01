#!/usr/bin/python3
import xml.etree.ElementTree as ET,gzip
import requests

BASE_URL="http://ftp.iij.ad.jp/pub/linux/centos/"
OS_VER="7"
ARCH="x86_64"
INSTALL=["basesystem", "yum", "strace", "vim-minimal", "less", "kernel", "tar", "dhclient", "openssh-server", "openssh-clients", "avahi"]

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

if __name__ == "__main__":
    r = requests.get(BASE_URL + "%s/os/%s/repodata/repomd.xml" % (OS_VER,ARCH))
    if r.status_code != 200: exit(1)
    #else

    primary = ET.fromstring(r.content).find("{http://linux.duke.edu/metadata/repo}data[@type='primary']/{http://linux.duke.edu/metadata/repo}location").attrib["href"]

    r = requests.get(BASE_URL + "%s/os/%s/%s" % (OS_VER,ARCH,primary))
    if r.status_code != 200: exit(1)

    for package in ET.fromstring(gzip.decompress(r.content)).findall("{http://linux.duke.edu/metadata/common}package[@type='rpm']"):
        arch = package.find("{http://linux.duke.edu/metadata/common}arch").text
        if arch not in [ARCH, "noarch"]: continue
        p = {
            "name": package.find("{http://linux.duke.edu/metadata/common}name").text,
            "arch": package.find("{http://linux.duke.edu/metadata/common}arch").text,
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

    for rpm in rpms:
        print(BASE_URL + "%s/os/%s/%s" % (OS_VER, ARCH, rpm))
    