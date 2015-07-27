import subprocess,json,copy,re,os

BLKID_PATTERN=re.compile(r'^(.+?)=(.+)$')

def blkid(device):
    vals = {}
    for line in subprocess.check_output(["blkid","-o","export",device]).splitlines():
        match = BLKID_PATTERN.search(line)
        if match is None: continue
        key, value = match.groups()
        vals[key] = value
    return vals

def get_all_domains():
    domains = {}
    for line in subprocess.check_output(["lvs","--noheadings","--units=g","--nosuffix","@wbvm","-o","lv_name,vg_name,lv_path,lv_tags,lv_size,lv_attr"], close_fds=True).splitlines():
        name, vg_name, device,tags,size,attr = [ x.strip() for x in line.split() ]
        blkid_vals = blkid(device)
        uuid = blkid_vals.get("UUID")
        fstype = blkid_vals.get("TYPE")
        if uuid is None or uuid == "": continue
        tags = tags.split(',')
        domains[uuid] = {"name":name,"vg_name":vg_name,"device":device,"autostart":"autostart" in tags,"size":int(float(size)),"writable":attr[1] == 'w',"open":attr[5] == 'o',"fstype":fstype}
    return domains

def get_running_domains():
    domains = {}
    with open(os.devnull, 'w') as devnull:
        xl = subprocess.check_output(["xl","list","-l"],stderr=devnull)

    for running_domain in json.loads(xl):
        domid = running_domain.get("domid")
        config = running_domain.get("config")
        if None in [domid, config]: continue

        b_info, c_info = (config.get("b_info"), config.get("c_info"))
        if None in [b_info, c_info]: continue

        uuid, name = (c_info.get("uuid"), c_info.get("name"))
        vcpus, memkb = (b_info.get("max_vcpus"), b_info.get("max_memkb"))
        if None in [uuid, name, vcpus, memkb]: continue

        domains[uuid] = {
            "id":domid,
            "xen_name":name,
            "vcpus":vcpus,
            "memkb":memkb
        }
    return domains

def merge(all_domains,running_domains):
    domains = copy.copy(all_domains)
    for uuid,domain in running_domains.iteritems():
        if uuid in domains:
            domains[uuid].update(domain)
        else:
            domains[uuid] = domain

    domain_list = []
    for uuid, domain in domains.iteritems():
        domain["uuid"] = uuid
        domain_list.append(domain)
    return domain_list

if __name__ == '__main__':
    row_format ="{:<3} {:<15} {:<16} {:>5} {:>6} {:>6} {:>4}"
    print row_format.format("RUN","NAME","VG","BOOT","DISK","RAM","#CPU")
    print "-------------------------------------------------------------"
    for domain in merge(get_all_domains(), get_running_domains()):
        memkb = domain.get("memkb")
        running = "*" if memkb is not None else ""
        print row_format.format(running,domain["name"],domain["vg_name"],"*" if domain.get("autostart") == True else "","%dG" % domain["size"],"%dM" % (memkb / 1024) if memkb is not None else "",domain.get("vcpus") or "")
