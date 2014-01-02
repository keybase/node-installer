import SimpleHTTPServer
import SocketServer
import re

PORT = 8000

class MyHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):

    latest_stable = "keybase-0.0.0.tgz"

    def do_GET(self):
        if self.path == "/latest-stable":
            self.send_response(301)
            self.send_header('Location',"http://localhost:%d/%s" % (PORT, self.latest_stable))
            self.end_headers()
        else:
            SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)


httpd = SocketServer.TCPServer(("", PORT), MyHandler)

print "serving at port", PORT
httpd.serve_forever()

