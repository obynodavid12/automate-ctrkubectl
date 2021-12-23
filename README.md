This will successfully install kubeadm and containerd runtime on vagrant creating one master node and 2 worker nodes

#Next Step
On the Master Node(kmaster) go into the root path
sudo -i

Run the below command to see the "kubeinit.log" file that was generated from the kmaster bootstrap script
ls

As the root user execute the below command gotten from the kubeinit.log file
export KUBECONFIG=/etc/kubernetes/admin.conf

Then finally check your nodes
kubectl get nodes
kubectl get pods -A

Connecting to the remote server via SSH. The password created is "kubeadmin" for logging into the remote servers in their root user path

