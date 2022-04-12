#!/bin/bash
set -x #echo on

########################################################################
## INITIALIZE (BOTH MASTER & WORKER) ###################################
sudo apt-get -y update
sudo apt-get -y upgrade
# sudo apt-get -y install curl git openssh-server net-tools

########################################################################
## COMMON (BOTH MASTER & WORKER) #######################################
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install containerd -y
sudo mkdir -p /etc/containerd
sudo containerd config default | tee /etc/containerd/config.toml
sudo systemctl restart containerd

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

########################################################################
## ONLY MASTER NODE ####################################################
# sudo kubeadm config images pull
# 
# KUBEADM_MY_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=$KUBEADM_MY_IP --control-plane-endpoint=$KUBEADM_MY_IP
# 
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 
# kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
# kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
