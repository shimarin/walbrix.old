import subprocess,json,copy

def get_all_domains():
    domains = {}
    for line in subprocess.check_output(["lvs","--noheadings","--nosuffix","@wbvm","-o","lv_name,vg_name,lv_path"], close_fds=True).splitlines():
        name, vg_name, device = map(lambda x:x.strip(), line.split())
        uuid = subprocess.check_output(["blkid","-s","UUID","-o","value",device]).strip()
        if uuid == "": continue
        domains[uuid] = {"name":name,"vg_name":vg_name,"device":device}
    return domains

def get_running_domains():
    domains = {}
    for running_domain in json.loads(subprocess.check_output(["xl","list","-l"])):
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
    for domain in merge(get_all_domains(), get_running_domains()):
        print domain
