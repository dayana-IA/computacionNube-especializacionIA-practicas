#!/usr/bin/env bash
set -e

IP_SERVER=$1

echo "--- Instalando dependencias ---"
sudo apt-get update -y

echo "--- Instalando Consul Haproxy ---"
sudo apt install -y haproxy
sudo systemctl enable haproxy

cat <<EOF | sudo tee /etc/haproxy/errors/503.http > /dev/null
HTTP/1.0 503 Servicio no disponible
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html>
    <body>
        <h1>Lo sentimos</h1>
        El servicio no esta disponible en este momento
    </body>
</html>
EOF

cat >> /etc/haproxy/haproxy.cfg <<EOF
frontend http
    bind *:80
    default_backend web-backend

backend web-backend
    balance roundrobin
    stats enable
    stats auth admin:admin
    stats uri /haproxy?stats

    server-template mymicroserviceapp 4 _mymicroservice._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
    nameserver consul ${IP_SERVER}:8600
    accepted_payload_size 8192
    hold valid 10s
EOF

sudo systemctl restart haproxy