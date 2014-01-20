import SimpleHTTPServer
import SocketServer
import re
import sys
import os
import os.path

PORT = 8000

#---------------------------------

def strip_leading_slashes(x):
    parts = x.split('/')
    last = 0
    for i,part in enumerate(parts):
        if len(part) > 0: break
        else: last = i+1
    parts = parts[last:]
    return "/".join(parts)

#---------------------------------

def make_safe (u):
    parts = u.split('/')
    v = []
    for part in parts:
        if part != '..':
            v.push(part)
    return "/".join(v)

#---------------------------------

class MyHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):

    def do_GET(self):
        raw = strip_leading_slashes(self.path)
        if os.path.islink(raw):
            res = make_safe(os.readlink(raw))
            self.send_response(301)
            self.send_header('Location',"http://localhost:%d/%s" % (PORT, res))
            self.end_headers()
        else:
            SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

#---------------------------------


httpd = SocketServer.TCPServer(("", PORT), MyHandler)

print "serving at port", PORT
httpd.serve_forever()

