#!/bin/bash

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/bin/

apt install -y jq

curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=v1.19.5+rke2r1 sh -
systemctl start rke2-server
until [ $(curl -k https://localhost:6443 |jq -r '.code') = "401" ]
do
    echo " waiting for KUBE API is UP....."
done
echo "KUBE API is UP...."

sed -i '/KUBECONFIG/d' ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml" >> ~/.bashrc
