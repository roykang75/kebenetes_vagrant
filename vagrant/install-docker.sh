sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y net-tools vim
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "192.168.1.100	k8s-master"       | tee -a /etc/hosts > /dev/null
echo "192.168.1.101	k8s-worker-node1" | tee -a /etc/hosts > /dev/null
echo "192.168.1.102	k8s-worker-node2" | tee -a /etc/hosts > /dev/null

### Disable SELinux
#echo "### Disable SELinux"
#setenforce 0
#sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux


### Add Docker’s official GPG key
echo "### Add Docker’s official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

### Add Docker apt repository.
echo '### Add Docker apt repository.'
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
echo "## Install Docker CE."
sudo apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

sudo usermod -aG docker vagrant

# Restart docker.
systemctl daemon-reload
systemctl restart docker

#sleep 5
#sudo usermod -aG docker vagrant
#sudo shutdown -r
