#!/bin/bash
# Not meant to be run
exit 0

# Apply NixOS configuration changes
sudo nixos-rebuild switch

# Disable swap, Load overlay module, Load br_netfilter module, Apply sysctl settings
sudo swapoff -a
sudo modprobe overlay || true
sudo modprobe br_netfilter || true
sudo sysctl --system

# Enable and start containerd service
sudo systemctl enable --now containerd
sudo systemctl status containerd

sudo containerd config default | sudo tee /etc/containerd/config.toml
# Otevři /etc/containerd/config.toml a ujisti se, že v CRI runtime options je SystemdCgroup = true. Pokud tam není, najdi blok: [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options] a ulož tam SystemdCgroup = true
sudo systemctl restart containerd

sudo systemctl enable --now kubelet
sudo systemctl status kubelet

sudo kubeadm init --cri-socket unix:///run/containerd/containerd.sock --pod-network-cidr=10.96.0.0/12
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Enable scheduling on control-plane node (optional, for single-node clusters)
sudo kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

# Install cillium
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzf cilium-linux-amd64.tar.gz 
sudo mv cilium /usr/local/bin/

cilium install
cilium status --wait

kubectl -n kube-system get pods -l k8s-app=cilium