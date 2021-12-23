#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
sudo apt install -qq -y sshpass >/dev/null 2>&1
sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1
