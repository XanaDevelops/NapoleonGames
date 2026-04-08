#!/usr/bin/env python3
"""
Servidor HTTP simple.

GET /?id=123 -> {"id":123, "method":"GET", "random": {"value": <int>}}
POST / with JSON {"id":123, "isValid":true} -> {"ok": true} or {"error": true}

Run:
  python server_http.py       # start server on port 8000
  python server_http.py 8080  # start server on port 8080
  python server_http.py --test  # run quick built-in tests
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import random
from urllib.parse import urlparse, parse_qs
import sys

class SimpleHandler(BaseHTTPRequestHandler):
    def _send_json(self, data, code=200):
        body = json.dumps(data).encode('utf-8')
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path != '/':
            self._send_json({'error': 'not found'}, code=404)
            return
        qs = parse_qs(parsed.query)
        id_list = qs.get('id')
        if not id_list:
            self._send_json({'error': 'missing id parameter'}, code=400)
            return
        try:
            id_val = int(id_list[0])
        except ValueError:
            self._send_json({'error': 'invalid id'}, code=400)
            return
        rand_int = random.randint(0, 2**31-1)
        self._send_json({'id': id_val, 'method': 'GET', 'random': {'value': rand_int}})

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path != '/':
            self._send_json({'error': 'not found'}, code=404)
            return
        content_length = int(self.headers.get('Content-Length', 0))
        raw = self.rfile.read(content_length) if content_length else b''
        try:
            data = json.loads(raw.decode('utf-8')) if raw else {}
        except Exception:
            self._send_json({'error': 'invalid json'}, code=400)
            return
        is_valid = data.get('isValid')
        if is_valid is True:
            self._send_json({'ok': True})
        else:
            self._send_json({'error': True})

    def log_message(self, format, *args):
        # Print minimal logs to stdout instead of stderr
        sys.stdout.write("%s - - [%s] %s\n" % (self.address_string(), self.log_date_time_string(), format%args))


def run_server(host='0.0.0.0', port=8000):
    server = HTTPServer((host, port), SimpleHandler)
    print(f"Listening on {host}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down")
        server.server_close()


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        import threading
        import time
        from urllib.request import urlopen, Request
        import urllib.parse

        t = threading.Thread(target=run_server, args=('127.0.0.1', 8000), daemon=True)
        t.start()
        time.sleep(0.2)

        # Test GET
        params = urllib.parse.urlencode({'id': 123})
        resp = urlopen(f'http://127.0.0.1:8000/?{params}')
        print('GET status', resp.getcode(), resp.read().decode())

        # Test POST valid
        req = Request('http://127.0.0.1:8000/', data=json.dumps({'id':123,'isValid':True}).encode('utf-8'), method='POST')
        req.add_header('Content-Type', 'application/json')
        resp = urlopen(req)
        print('POST valid', resp.getcode(), resp.read().decode())

        # Test POST invalid
        req = Request('http://127.0.0.1:8000/', data=json.dumps({'id':123,'isValid':False}).encode('utf-8'), method='POST')
        req.add_header('Content-Type', 'application/json')
        resp = urlopen(req)
        print('POST invalid', resp.getcode(), resp.read().decode())
    else:
        port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
        run_server('0.0.0.0', port)
