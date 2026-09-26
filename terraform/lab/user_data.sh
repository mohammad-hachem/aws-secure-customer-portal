#!/bin/bash
set -euxo pipefail

dnf install -y python3-boto3 python3-psycopg2

mkdir -p /opt/secure-portal

cat > /opt/secure-portal/app.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import boto3
import json
import socket
import psycopg2
import html

REGION = "eu-central-1"
SECRET_ID = "aws-secure-portal/db-credentials"


def get_db_secret():
    client = boto3.client(
        "secretsmanager",
        region_name=REGION
    )

    response = client.get_secret_value(
        SecretId=SECRET_ID
    )

    return json.loads(response["SecretString"])


def query_database():
    secret = get_db_secret()

    conn = psycopg2.connect(
        host=secret["host"],
        port=secret["port"],
        dbname=secret["dbname"],
        user=secret["username"],
        password=secret["password"],
        sslmode="require",
        connect_timeout=5
    )

    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, message, created_at
                FROM portal_test
                ORDER BY id DESC
                LIMIT 10;
            """)

            return cur.fetchall()
    finally:
        conn.close()


class PortalHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()

            response = {
                "status": "healthy",
                "host": socket.gethostname()
            }

            self.wfile.write(json.dumps(response).encode())

        elif self.path == "/":
            try:
                rows = query_database()
                row_html = ""

                for row in rows:
                    row_html += f"""
                    <tr>
                      <td>{row[0]}</td>
                      <td>{html.escape(str(row[1]))}</td>
                      <td>{html.escape(str(row[2]))}</td>
                    </tr>
                    """

                page = f"""
                <html>
                  <head>
                    <title>AWS Secure Customer Portal</title>
                  </head>
                  <body>
                    <h1>AWS Secure Customer Portal</h1>
                    <p>Application server: <strong>{html.escape(socket.gethostname())}</strong></p>
                    <p>Secrets Manager authentication: <strong>Successful</strong></p>
                    <p>PostgreSQL connection: <strong>Successful</strong></p>

                    <h2>Database Records</h2>

                    <table border="1" cellpadding="6">
                      <tr>
                        <th>ID</th>
                        <th>Message</th>
                        <th>Created At</th>
                      </tr>
                      {row_html}
                    </table>
                  </body>
                </html>
                """

                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                self.wfile.write(page.encode())

            except Exception as exc:
                print(f"Application error: {exc}", flush=True)

                self.send_response(500)
                self.send_header("Content-Type", "text/html")
                self.end_headers()

                self.wfile.write(b"""
                <html>
                  <body>
                    <h1>AWS Secure Customer Portal</h1>
                    <p>Database request failed.</p>
                  </body>
                </html>
                """)

        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        print(
            "%s - %s" %
            (
                self.address_string(),
                format % args
            ),
            flush=True
        )


server = HTTPServer(
    ("0.0.0.0", 3000),
    PortalHandler
)

print(
    "AWS Secure Customer Portal listening on port 3000",
    flush=True
)

server.serve_forever()
PY

cat > /etc/systemd/system/secure-portal.service <<'EOF'
[Unit]
Description=AWS Secure Customer Portal
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/secure-portal/app.py
Restart=always
RestartSec=5
User=nobody

[Install]
WantedBy=multi-user.target
EOF

chown root:root /opt/secure-portal/app.py
chmod 0644 /opt/secure-portal/app.py

systemctl daemon-reload
systemctl enable secure-portal
systemctl restart secure-portal
