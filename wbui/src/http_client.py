# -*- coding: utf-8 -*-

import subprocess
import system

import gui
import resource_loader



CA_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"

# string resources

gui.res.register("string_not_resolve",resource_loader.l({"en":u"Could not resolve host name", "ja":u"ホスト名を解決できませんでした"}))
gui.res.register("string_http_server_error",resource_loader.l({"en":u"HTTP server returned an error", "ja":u"HTTPサーバがエラーを返しました"}))
gui.res.register("string_ssl_error",resource_loader.l({"en":u"We were unable to verify the reliability of the SSL certificate", "ja":u"SSL証明書の信頼性を確認できませんでした"}))
gui.res.register("string_curl_http_error",resource_loader.l({"en":u"HTTP error curl: %d", "ja":u"HTTPエラーです curl:%d"}))



class Cancelled(Exception):
    pass

class CurlException(Exception):
    def __init__(self, code, url):
        self.code = code
        self.url = url
        Exception.__init__(self)
    def getCode(self):
        return self.code
    def getError(self):
        code = self.getCode()
        if code == 6: return gui.res.string_not_resolve
        if code == 22: return gui.res.string_http_server_error
        if code == 60: return gui.res.string_ssl_error
        return gui.res.string_curl_http_error % code

    def getURL(self):
        return self.url

def nonblockingHttpHead(url):
    cmdline = ["curl", "--cacert", CA_CERT_FILE, "-sLfI", url]
    curl = subprocess.Popen(cmdline, shell=False, close_fds=True, stdout=subprocess.PIPE)
    s = system.getSystem()
    headers = {}
    nbr = s.getNonblockingReader(curl.stdout)
    r = nbr.readline()
    started = False
    while r != "":
        if r != None:
            if started:
                splitted = r.split(':', 1)
                if len(splitted) > 1:
                    name = splitted[0].strip().lower()
                    value = splitted[1].strip()
                    if name == "content-length": value = int(value)
                    headers[name] = value
            else:
                line = r.strip()
                if line.startswith("HTTP/") and line.endswith(" 200 OK"):
                    started = True
        if gui.yieldFrame(): # キャンセルキーでTrueが返る
            curl.terminate()
            raise Cancelled()
        r = nbr.readline()
    curl.stdout.close()
    rst = curl.wait()
    if rst != 0: raise CurlException(rst, url)
    return headers
    

def nonblockHttpGet(url):
    cmdline = ["curl", "--cacert", CA_CERT_FILE, "-sLf", url]
    curl = subprocess.Popen(cmdline, shell=False, close_fds=True, stdout=subprocess.PIPE)
    s = system.getSystem()
    nbr = s.getNonblockingReader(curl.stdout)
    buf = ""
    r = nbr.read()
    while r != "":
        if r != None: buf += r
        if gui.yieldFrame(): # キャンセルキーでTrueが返る
            curl.terminate()
            raise Cancelled()
        r = nbr.read()
    curl.stdout.close()
    rst = curl.wait()
    if rst != 0: raise CurlException(rst, url)
    return buf
