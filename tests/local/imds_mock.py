"""Imita o Instance Metadata Service (IMDSv2) da AWS para a simulação local.

Responde em 169.254.169.254 e devolve metadados diferentes conforme o IP de
quem pergunta, como se cada container fosse uma instância do ASG. Sem o token
do PUT /latest/api/token, os GETs recebem 401, igual à AWS com IMDSv2 exigido.
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import secrets

INSTANCES = {
    "169.254.169.10": {"instance-id": "i-0a1a5im0000000001", "placement/availability-zone": "us-east-1a",
                       "local-ipv4": "10.0.2.10", "instance-type": "t2.micro"},
    "169.254.169.20": {"instance-id": "i-0c1c5im0000000002", "placement/availability-zone": "us-east-1c",
                       "local-ipv4": "10.0.4.20", "instance-type": "t2.micro"},
}
TOKENS = set()


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, body=""):
        data = body.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_PUT(self):
        if self.path == "/latest/api/token" and self.headers.get("X-aws-ec2-metadata-token-ttl-seconds"):
            token = secrets.token_urlsafe(24)
            TOKENS.add(token)
            return self._send(200, token)
        self._send(400)

    def do_GET(self):
        if self.headers.get("X-aws-ec2-metadata-token") not in TOKENS:
            return self._send(401)
        prefix = "/latest/meta-data/"
        data = INSTANCES.get(self.client_address[0], {})
        key = self.path[len(prefix):] if self.path.startswith(prefix) else None
        if key in data:
            return self._send(200, data[key])
        self._send(404)

    def log_message(self, *args):
        pass


ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
