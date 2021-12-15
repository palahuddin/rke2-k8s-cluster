#!/bin/bash



until [ $(curl localhost | awk '{print $4}') = "404" ]
do 
echo " Waiting for all nodes is Ready"
done

export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

helm repo add jetstack https://charts.jetstack.io
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.2/cert-manager.crds.yaml
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --version v0.15.2 \
 
kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm fetch rancher-stable/rancher --version=2.5.5
kubectl create namespace cattle-system
helm install rancher rancher-stable/rancher --version=v2.5.5 \
  --namespace cattle-system \
  --set hostname=rke2.cluster
