# -*- coding:utf-8 -*-

import os
import stat
import subprocess
import shutil
import tempfile
import urlparse
import BaseHTTPServer

private_key_file = "/etc/openvpn/client.key"

class RequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):

	def send_file(self, filename, content_type):
		self.send_response(200)
		self.send_header("content-type", content_type)
		self.end_headers() 
		with open(filename, "r") as file:
			self.wfile.write(file.read())

	def send_screenshot(self):
		tmpfile = "/tmp/wb-screenshot.png"
		subprocess.Popen("fbgrab %s" % (tmpfile), shell=True, stdout=subprocess.PIPE, close_fds=True).wait()

		if os.path.isfile(tmpfile):
			self.send_response(200)
			self.send_header("content-type", "image/png")
			self.end_headers() 
			with open(tmpfile, "r") as file:
				self.wfile.write(file.read())
			os.unlink(tmpfile)
		else:
			self.send_response(500, "Screenshot couldn't be taken")

	def issue_csr(self, serial):
		if not os.path.isfile(private_key_file):
			subprocess.Popen("openssl genrsa -out %s" % (private_key_file), shell=True, close_fds=True).wait()
		if not os.path.isfile(private_key_file):
			self.send_response(500, "Couldn't generate private key")
			return
		openssl = subprocess.Popen("openssl req -new -subj '/CN=%s' -key %s" % (serial, private_key_file), shell=True, stdout=subprocess.PIPE, close_fds=True)

		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()
		self.wfile.write(openssl.stdout.read())

		openssl.wait()
	
	def export_key(self, passphrase):
		if passphrase == None: passphrase = ""
		openssl = subprocess.Popen("openssl rsa %s -passout 'pass:%s' -in %s" % ("-des" if passphrase != "" else "", passphrase, private_key_file), shell=True, stdout=subprocess.PIPE, close_fds=True)

		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()
		self.wfile.write(openssl.stdout.read())

		openssl.wait()

	def send_crt(self):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()

		try:
			if not os.path.isfile("/etc/openvpn/client.crt"):
				self.wfile.write("")
				return
			with open("/etc/openvpn/client.crt") as crt:
				self.wfile.write(crt.read())
		except Exception, e:
			self.wfile.write("READ ERROR: /etc/openvpn/client.crt")

	def send_subject(self):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()

		try:
			if not os.path.isfile("/etc/openvpn/client.crt"):
				self.wfile.write("NO")
				return
			openssl = subprocess.Popen("openssl x509 -subject -noout -in /etc/openvpn/client.crt", shell=True, stdout=subprocess.PIPE, close_fds=True)
			subject = openssl.stdout.readline()
			if openssl.wait() != 0 or subject == None:
				raise Exception("OpenSSL couldn't identify certificate")
			self.wfile.write(subject)
		except Exception, e:
			self.wfile.write("ERROR %s" % e)
			return

	def put_crt(self, crt):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()

		try:
			tmpname = "/tmp/wb-client-certificate"
			with open(tmpname, "w") as tmpcrt:
				tmpcrt.write(crt)
			openssl = subprocess.Popen("openssl x509 -subject -noout -in %s" % (tmpname), shell=True, stdout=subprocess.PIPE, close_fds=True)
			subject = openssl.stdout.readline()
			if openssl.wait() != 0 or subject == None:
				raise Exception("OpenSSL couldn't identify certificate")
			cn = None
			subparts = subject.split('/')
			for part in subparts:
				if part.startswith("CN="):
					cn = part[3:].strip()
					break
			if cn == None:
				raise Exception("No Common Name(CN) in the certificate")
			shutil.move(tmpname, "/etc/openvpn/client.crt")
			with open("/etc/conf.d/hostname", "w") as hostname:
				hostname.write('HOSTNAME="%s"' % (cn))
			subprocess.Popen("hostname %s" % (cn), shell=True, close_fds=True).wait()
			
		except Exception, e:
			self.wfile.write(e)
			return

		self.wfile.write("OK")

	def put_key(self, key, passphrase, override):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()
		
		if os.path.exists(private_key_file):
			if not override:
				self.wfile.write("Key file already exists")
				return
			elif not os.path.isfile(private_key_file):
				self.wfile.write("Something looks like keyfile exists but not a regular file")
				return

		if passphrase == None: passphrase = ""

		openssl = subprocess.Popen("openssl rsa -passin 'pass:%s' -out %s" % (passphrase, private_key_file), shell=True, stdin=subprocess.PIPE, close_fds=True)
		openssl.stdin.write(key)
		openssl.stdin.close()
		if openssl.wait() != 0:
			self.wfile.write("Corrupted key or wrong passphrase")
			return

		self.wfile.write(u"OK")

	def send_authorized_keys(self):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()

		try:
			if os.path.isfile("/root/.ssh/authorized_keys"):
				with open("/root/.ssh/authorized_keys", "r") as ak:
					self.wfile.write(ak.read())
			else:
				self.wfile.write("")
		except Exception, e:
			self.wfile.write("ERROR")

	def put_authorized_keys(self, authorized_keys):
		self.send_response(200)
		self.send_header("content-type", "text/plain")
		self.end_headers()

		try:
			if not os.path.isdir("/root/.ssh"):
				os.mkdir("/root/.ssh")
			os.chmod("/root/.ssh", stat.S_IRWXU)
			with open("/root/.ssh/authorized_keys", "w") as ak:
				ak.write(authorized_keys)
			os.chmod("/root/.ssh/authorized_keys", stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)

		except Exception, e:
			self.wfile.write(e)
			return

		self.wfile.write(u"OK")

	def log_request(self, code, size=None):
		pass

	def do_GET(self):
		splitted = urlparse.urlsplit(self.path)
		path = splitted.path
		query = splitted.query
		params = urlparse.parse_qs(query, True)
		if path == "/":
			self.send_file("index.html", "text/html;charset=UTF-8")
			return
		if path == "/favicon.ico":
			self.send_file("favicon.ico", "image/vnd.microsoft.icon")
			return
		if path == "/screenshot.png":
			self.send_screenshot()
			return
		if path == "/csr.txt":
			if 'serial' in params:
				self.issue_csr(params['serial'][0])
			else:
				self.send_error(400, "Parameter 'serial' is missing.")
			return
		if path == "/key.txt":
			self.export_key(params['passphrase'][0])
			return
		if path == "/authorized_keys.txt":
			self.send_authorized_keys()
			return
		if path == "/crt.txt":
			self.send_crt()
			return
		if path.endswith(".css"):
			if path.startswith("/"):
				path = "." + path
			self.send_file(path, "text/css")
			return
		if path.endswith(".png"):
			if path.startswith("/"):
				path = "." + path
			self.send_file(path, "image/png")
			return

		self.send_error(404, "Not found")

	def do_POST(self):
		path = self.path
		length = int(self.headers.getheader('content-length'))
		params = urlparse.parse_qs(self.rfile.read(length), True)
		if path == "/crt":
			if 'crt' in params:
				self.put_crt(params['crt'][0])
			else:
				self.send_error(400, "Parameter 'crt' is missing.")
			return
		if path == "/key":
			if 'key' in params:
				passphrase = params['passphrase'][0] if 'passphrase' in params else None
				override = params['override'][0] == 'true' if 'override' in params else False
				self.put_key(params['key'][0], passphrase, override)
			else:
				self.send_error(400, "Parameter 'key' is missing.")
			return
			
		if path == "/authorized_keys":
			if 'ak' in params:
				self.put_authorized_keys(params['ak'][0])
			else:
				self.send_error(400, "Parameter 'ak' is missing.")
			return

		self.send_error(404, "Not found")
