#!/usr/bin/env python3
"""Typing Lab: serves the page on localhost and stores every test as a JSON file in data/sessions/.

Usage: ./server.py            (opens the browser)
       ./server.py --no-open
Port: TYPING_LAB_PORT (default 8765)
"""
import json
import os
import re
import sys
import webbrowser
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(ROOT, "data", "sessions")
PORT = int(os.environ.get("TYPING_LAB_PORT", "8765"))
SESSION_ID = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
PUBLIC = {"/", "/index.html", "/words.js"}


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def log_message(self, fmt, *args):
        pass

    def send_json(self, code, obj):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def session_path(self):
        sid = self.path[len("/api/sessions/"):]
        return os.path.join(DATA, sid + ".json") if SESSION_ID.match(sid) else None

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/api/sessions":
            sessions = []
            for name in sorted(os.listdir(DATA)):
                if name.endswith(".json"):
                    try:
                        with open(os.path.join(DATA, name), encoding="utf-8") as f:
                            sessions.append(json.load(f))
                    except (OSError, ValueError):
                        pass
            return self.send_json(200, sessions)
        if path not in PUBLIC:
            return self.send_json(404, {"error": "not found"})
        self.path = path
        return super().do_GET()

    def do_PUT(self):
        target = self.session_path() if self.path.startswith("/api/sessions/") else None
        if not target:
            return self.send_json(400, {"error": "bad session id"})
        try:
            length = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(length))
            if not isinstance(data, dict):
                raise ValueError
        except ValueError:
            return self.send_json(400, {"error": "body must be a JSON object"})
        tmp = target + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)
        os.replace(tmp, target)
        return self.send_json(200, {"ok": True})

    def do_DELETE(self):
        target = self.session_path() if self.path.startswith("/api/sessions/") else None
        if not target:
            return self.send_json(400, {"error": "bad session id"})
        if os.path.exists(target):
            os.remove(target)
        return self.send_json(200, {"ok": True})


def main():
    os.makedirs(DATA, exist_ok=True)
    server = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    url = f"http://127.0.0.1:{PORT}/"
    print(f"Typing Lab running at {url}  (data: {DATA})  Ctrl+C to stop")
    if "--no-open" not in sys.argv:
        webbrowser.open(url)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
