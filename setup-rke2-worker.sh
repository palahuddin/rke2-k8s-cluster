#!/bin/bash

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" INSTALL_RKE2_VERSION=v1.19.5+rke2r1 sh -
mkdir -p /etc/rancher/rke2/
echo "
server: https://$(cat master-ip):9345
token: $(cat master-token)
" > /etc/rancher/rke2/config.yaml
systemctl start rke2-agent.service
