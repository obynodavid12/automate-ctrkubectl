#!/bin/bash

## !IMPORTANT ##
#
## This script is tested only in the ubuntu/bionic64 Vagrant box
## If you use a different version of Ubuntu or a different Ubuntu Vagrant box test this again
#

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Enable and Load Kernel modules"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "[TASK 4] Add Kernel settings"
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system >/dev/null 2>&1

echo "[TASK 5] Install containerd runtime"
sudo apt update -qq >/dev/null 2>&1
sudo apt install -qq -y containerd apt-transport-https ca-certificates curl >/dev/null 2>&1
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd >/dev/null 2>&1

echo "[TASK 6] Add apt repo for kubernetes"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - >/dev/null 2>&1
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl)"
sudo apt-get update
sudo apt install -qq -y kubeadm=1.23.0-00 kubelet=1.23.0-00 kubectl=1.23.0-00 >/dev/null 2>&1

# echo "[TASK 8] Set up sudo"
# sudo echo vagrant ALL=NOPASSWD:ALL > /etc/sudoers.d/vagrant
# sudo chmod 755 /etc/sudoers.d/vagrant

# echo "[TASK 9] Setup sudo to allow no-password sudo"
# sudo usermod -a -G sudo vagrant

echo "[TASK 10] Enable ssh password authentication"
sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
sudo systemctl reload sshd

echo "[TASK 11] Set root password"
sudo echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
sudo echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 12] Update /etc/hosts file"
sudo cat >>/etc/hosts<<EOF
192.168.33.100  kmaster     
192.168.33.101  kworker1    
192.168.33.102  kworker2    
EOF
