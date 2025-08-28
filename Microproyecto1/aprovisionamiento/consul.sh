#!/usr/bin/env bash
set -e

CONSUL_TYPE=$1
IP=$2
IP_SERVER=$3

echo "--- Instalando dependencias ---"
sudo apt-get update -y
sudo apt-get install -y wget

echo "--- Instalando Consul ---"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo sudo apt update && sudo apt install consul
if [ "$CONSUL_TYPE" = "server" ]; then
  nohup consul agent -server -ui -bootstrap-expect=1 \
    -bind=$IP \
    -client=0.0.0.0 \
    -data-dir=. \
    > /vagrant/consul-server.log 2>&1 &
else
  nohup consul agent \
  -bind=$IP \
  -client=0.0.0.0 \
  -data-dir=. \
  -retry-join=$IP_SERVER \
  > /vagrant/consul-agent.log 2>&1 &
fi