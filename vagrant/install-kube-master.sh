sudo apt-get update && sudo apt-get upgrade -y

# install Kube
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo '================================================================================'
echo ' swapoff -a'
sudo swapoff -a
echo '================================================================================'
echo ' sudo apt-get install -y kubelet kubeadm kubectl'
sudo apt-get install -y kubelet kubeadm kubectl
kubeadm version

sleep 5

echo '================================================================================'
sudo kubeadm init --apiserver-advertise-address 192.168.1.100 --pod-network-cidr 172.168.10.0/24
#sudo kubeadm init --apiserver-advertise-address 192.168.1.100
echo '================================================================================'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 20

echo '================================================================================'
echo ' Weave net installation'
#sudo -i
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

sleep 20

echo '================================================================================'
echo ' kubectl get nodes'
kubectl get nodes

sleep 1m

echo '================================================================================'
#sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#echo '================================================================================'
echo ' sudo kubectl get pods --all-namespaces'
sudo kubectl get pods --all-namespaces

