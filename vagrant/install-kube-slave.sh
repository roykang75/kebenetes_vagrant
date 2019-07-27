sudo apt-get update && sudo apt-get upgrade -y

# install Kube
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo swapoff -a
sudo apt-get install -y kubeadm 
kubeadm version

sleep 5

echo '================================================================================'
#sudo kubeadm init --pod-network-cidr=172.168.10.0/24
sudo kubeadm init --apiserver-advertise-address 192.168.1.100 --pod-network-cidr 172.168.10.0/24
echo '================================================================================'

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


