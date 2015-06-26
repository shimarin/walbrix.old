'''
Created on 2011/05/23

@author: shimarin
'''

import sys
import socket
import cli

usage = "backup_id backup_host"

def send_stream_via_http(stream, head, location, content_type, host, port=8080):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host,port))
    try:
        s.sendall("PUT %s HTTP/1.0\n" % (location))
        s.sendall("Content-Type: %s\n\n" % (content_type))
        s.sendall(head)
        buf = stream.read(1024)
        while buf != "":
            s.sendall(buf)
            buf = stream.read(1024)
    finally:
        s.close()

def setupOptions(parser):
    pass

def run(options, args):
    if len(args) < 2: raise cli.Error("Insufficient parameters.")

    backupId = args[0]
    backupHost = args[1]

    buf = sys.stdin.read(512)
    if len(buf) < 512: raise cli.Error("Input source is too short.")
    
    contentType = "application/x-tar" if buf[257:262] == "ustar" else "application/octet-stream"
    print >>sys.stderr, "Content-type: %s" % contentType

    send_stream_via_http(sys.stdin, buf, "/%s" %backupId, contentType, backupHost)
