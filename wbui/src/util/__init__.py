#!/usr/bin/python2.7
# -*- coding:utf-8 -*-

import sys,os,subprocess,base64,re,stat,tempfile,shutil,multiprocessing,signal,SocketServer
import BaseHTTPServer

import handler

import flask

app = flask.Flask(__name__)

key = "/etc/openvpn/client.key"
cert = "/etc/openvpn/client.crt"
cn_pattern = re.compile(r'^subject=.*/CN=(.+?)($|\/)', re.MULTILINE)

# ユーティリティ(HTTPベース)
utility = None
utility_port = None

def start_utility():
    global utility
    global utility_port

    q = multiprocessing.Queue()
    utility = multiprocessing.Process(target=run, args=(q, 0))
    utility.daemon = True
    utility.start()
    utility_port = q.get(True, 1)
    
    return utility_port

def stop_utility():
    global utility
    if utility is None: return False
    if utility.is_alive():
        utility.terminate()
        utility.join()
    utility = None
    return True

def is_utility_running():
    return utility != None and utility.is_alive()

def get_utility_port():
    if not is_utility_running(): return None
    global utility_port
    return utility_port

def main(port = 0):
    script_path = os.path.abspath(os.path.dirname(__file__))
    os.chdir(script_path)

    server_address = ('', port)
    httpd = BaseHTTPServer.HTTPServer(server_address, handler.RequestHandler)
    print httpd.server_address[1]
    sys.stdout.flush()
    httpd.serve_forever()

@app.route("/")
def index():
    return app.send_static_file('index.html')

@app.route("/status")
def status():
    return flask.jsonify({"key":os.path.isfile(key),"cert":os.path.isfile(cert)})

@app.route("/screenshot")
def screenshot_txt():
    image = subprocess.check_output(["fbgrab","-"])
    response = flask.make_response("data:image/png;base64," + base64.b64encode(image))
    response.headers['Content-Type'] = 'text/plain'
    return response

@app.route("/authorized_keys",methods=['GET'])
def get_authorized_keys():
    authorized_keys_path = os.path.expanduser("~/.ssh/authorized_keys")
    response = flask.make_response(open(authorized_keys_path).read() if os.path.isfile(authorized_keys_path) else "")
    response.headers['Content-Type'] = 'text/plain'
    return response

@app.route("/authorized_keys",methods=['POST','PUT'])
def post_authorized_keys():
    ssh_path = os.path.expanduser("~/.ssh")
    authorized_keys_path = os.path.join(ssh_path, "authorized_keys")
    authorized_keys = flask.request.data.replace(r"\r\n", r"\n")
    if authorized_keys[-1] != '\n': authorized_keys += '\n'

    try:
        if not os.path.isdir(ssh_path):
            os.mkdir(ssh_path)
            os.chmod(ssh_path, stat.S_IRWXU)
        with open(authorized_keys_path, "w") as ak:
            ak.write(authorized_keys)
        os.chmod(authorized_keys_path, stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)
    except Exception, e:
        print e
        return "400 Bad Request", 400

    return flask.jsonify({"success":True})

@app.route("/csr",methods=["GET"])
def get_csr():
    if not os.path.isfile(key):
        subprocess.check_call(["openssl","genrsa","-out",key])
    
    cn = flask.request.args.get("cn")
    if cn is None: return "400 Bad Request"
    csr = subprocess.check_output(["openssl","req","-new","-subj","/CN=%s" % cn,"-key",key])
    response = flask.make_response(csr)
    response.headers['Content-Type'] = 'text/plain'
    return response

def get_cn(cert_filename=cert):
    cn_match = cn_pattern.search(subprocess.check_output(["openssl","x509","-subject","-noout","-in",cert_filename]))
    if cn_match is None: return None
    return cn_match.groups()[0]

@app.route("/crt",methods=["POST","PUT"])
def post_crt():
    with tempfile.NamedTemporaryFile(delete=True) as tmpfile:
        tmpfile.write(flask.request.data.replace(r"\r\n", r"\n"))
        tmpfile.flush()
        cn = get_cn(tmpfile)
        if cn is None: return "400 Bad Request", 400
        #else
        shutil.copy(tmpfile, cert)
        
    with open("/etc/conf.d/hostname", "w") as hostname:
        hostname.write('hostname="%s"' % cn)

    subprocess.call(["hostname",cn])

    return flask.jsonify({"success":True})

@app.route("/pkcs12",methods=["GET"])
def get_pkcs12():
    if not os.path.isfile(key) or not os.path.isfile(cert): return "404 Not found", 404

    cn = get_cn()
    if cn is None: return "404 CN Not found from cert", 404
   
    pkcs12 = subprocess.check_output(["openssl","pkcs12","-export","-password","pass:","-in",cert,"-inkey",key])
    response = flask.make_response(base64.encodestring(pkcs12))
    response.headers['Content-Type'] = "text/plain"
    return response

@app.route("/pkcs12",methods=["POST","PUT"])
def post_pkcs12():
    pkcs12 = base64.decodestring(flask.request.data.replace(r"\r\n", r"\n"))

    with tempfile.NamedTemporaryFile(delete=True) as tmpfile:
        p = subprocess.Popen(["openssl","pkcs12","-nomacver","-clcerts","-nokeys","-password","pass:","-out",tmpfile.name],stdin=subprocess.PIPE)
        p.stdin.write(pkcs12)
        p.stdin.close()
        p.wait()
        cert_contents = open(tmpfile.name).read()

    with tempfile.NamedTemporaryFile(delete=True) as tmpfile:
        p = subprocess.Popen(["openssl","pkcs12","-nomacver","-nocerts","-nodes","-password","pass:","-out",tmpfile.name],stdin=subprocess.PIPE)
        p.stdin.write(pkcs12)
        p.stdin.close()
        p.wait()
        key_contents = open(tmpfile.name).read()

    cn_match = cn_pattern.search(cert_contents)
    if cn_match is None: return "400 Bad Request(No CN found from cert)", 400
    cn = cn_match.groups()[0]

    with open(key, "w") as f:
        f.write(key_contents)

    with open(cert, "w") as f:
        f.write(cert_contents)

    return flask.jsonify({"success":True})

class DummyQueue:
    def put(self, obj):
        print obj

def run(q, port = 0,debug=False):
    signal.signal(signal.SIGTERM, signal.SIG_DFL)
    try:
        original_socket_bind = SocketServer.TCPServer.server_bind
        def socket_bind_wrapper(self):
            ret = original_socket_bind(self)
            q.put(self.socket.getsockname()[1])
            SocketServer.TCPServer.server_bind = original_socket_bind
            return ret

        SocketServer.TCPServer.server_bind = socket_bind_wrapper
        app.run(host='0.0.0.0',port=port)
    except Exception, e:
        q.put(e)
    
if __name__ == '__main__':
    run(DummyQueue(), None, True)


