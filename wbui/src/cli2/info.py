import subprocess,re

INT_FIELDS = set(["nr_cpus", "max_cpu_id", "nr_nodes", "cores_per_socket", "threads_per_core", "cpu_mhz", "total_memory", "free_memory", "free_cpus", "xen_major", "xen_minor", "xen_pagesize", "xend_config_format"])

def run():
    pattern = re.compile(r'^(\S+)\s*:\s*(.*)$')
    vals = {}
    for line in subprocess.check_output(["xl","info"]).splitlines():
        match = pattern.search(line)
        if match is None: continue
        key, value = match.groups()
        vals[key] = int(value) if key in INT_FIELDS else value

    return vals

def get_free_memory_in_mb():
    try:
        vals = run()
        return (vals["free_memory"], vals["total_memory"])
    except:
        return (None, None)

if __name__ == '__main__':
    print run()
