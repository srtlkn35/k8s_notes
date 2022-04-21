#!/bin/bash
set -x #echo on

########################################################################
## SETUP ###############################################################
sudo apt-get -y install postgresql-client-common

sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/postresql_setup/postgres-configmap.yaml
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/postresql_setup/postgres-storage.yaml
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/postresql_setup/postgres-deployment.yaml
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/postresql_setup/postgres-service.yaml

kubectl apply -f postgres-configmap.yaml
kubectl apply -f postgres-storage.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

kubectl get all
