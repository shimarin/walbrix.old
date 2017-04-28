import os,socket,fcntl,struct,json

def get_interface_reaches_default_gateway():
    if not os.path.isfile("/proc/net/route"): return None
    with open("/proc/net/route", "r") as routes:
        line = routes.readline()
        if not line: return None
        line = routes.readline()
        while line:
            cols = line.split()
            if len(cols) > 2:
                ifname = cols[0]
                destination = cols[1]
                if destination == "00000000":
                    return ifname

            line = routes.readline()
    return "eth0"

def get_ipaddress(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname[:15])
            )[20:24])

def get_proxy_map():
    return open("/etc/nginx/proxy.map").read()

def get_cli_ini():
    return open("/etc/letsencrypt/cli.ini").read()

def application(env, start_response):
    start_response('200 OK', [('Content-Type','application/json')])
    ipv4_address = get_ipaddress(get_interface_reaches_default_gateway())
    proxy_map = get_proxy_map()
    cli_ini = get_cli_ini()
    return json.dumps({"ipv4_address":ipv4_address,"proxy_map":proxy_map,"cli_ini":cli_ini})

def func(a, b):
    print a, b

if __name__ == '__main__':
    print application(None, func)
