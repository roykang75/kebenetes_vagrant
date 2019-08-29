### Setup Kubernetes

---
Kubernetes 설치 방법에 대해 설명합니다.

### 설치환경

> OS: ubuntu 18.04 server LTS  
> Docker version: docker-ce=18.06.2~ce~3-0~ubuntu

### 공통 설치 항목 (docker)

master/node 공통으로 설치되어야 하는 항목에 대해 기술합니다.
```
$ sudo apt-get update && sudo apt-get upgrade -y
$ sudo apt-get install -y net-tools vim
$ sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

### Add Docker’s official GPG key
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

### Add Docker apt repository.
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

### Install Docker CE.
$ sudo apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu

### Setup daemon.
$ cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
$ mkdir -p /etc/systemd/system/docker.service.d
$ sudo usermod -aG docker $USER

### Restart docker.
$ systemctl daemon-reload
$ systemctl restart docker
```

master, node 의 swap partition을 제거 합니다.
```
$ sudo vim /etc/fstab
UUID=53386026-b39c-48c7-9469-51bbfbd8483c / ext4 defaults 0 0
#/swap.img      none    swap    sw      0       
```

### master (k8s master machine)

설치 명령은 다음과 같습니다.
```
$ sudo apt-get update && sudo apt-get upgrade -y

### install Kubernetes
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
$ sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

### 'swapoff -a'
$ sudo swapoff -a
$ sudo apt-get install -y kubelet kubeadm kubectl
$ kubeadm version

### sudo kubeadm init --apiserver-advertise-address <master-ip-address> --pod-network-cidr 172.168.10.0/24
$ sudo kubeadm init --apiserver-advertise-address 192.168.1.40 --pod-network-cidr 172.168.10.0/24
[init] Using Kubernetes version: v1.15.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'

[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.40]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master localhost] and IPs [192.168.1.40 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master localhost] and IPs [192.168.1.40 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 48.505802 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: q62o8l.s93ppgg1nyvl66eg
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.40:6443 --token q62o8l.s93ppgg1nyvl66eg \
    --discovery-token-ca-cert-hash sha256:7ceafa6b28c940158115e564633be55c8022d638976d7a1353416ffeeb6462d4 

$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

### Weave net installation
$ export kubever=$(kubectl version | base64 | tr -d '\n')
$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.extensions/weave-net created

$ kubectl get nodes
NAME     STATUS     ROLES    AGE     VERSION
master   NotReady   master   2m24s   v1.15.3

$ kubectl get pods --all-namespaces
NAMESPACE     NAME                             READY   STATUS              RESTARTS   AGE
kube-system   coredns-5c98db65d4-hfq9h         0/1     Pending             0          2m12s
kube-system   coredns-5c98db65d4-rm5tf         0/1     Pending             0          2m12s
kube-system   etcd-master                      1/1     Running             0          96s
kube-system   kube-apiserver-master            1/1     Running             0          86s
kube-system   kube-controller-manager-master   1/1     Running             0          97s
kube-system   kube-proxy-fvfjt                 1/1     Running             0          2m12s
kube-system   kube-scheduler-master            1/1     Running             0          91s
kube-system   weave-net-rrzk7                  0/2     ContainerCreating   0          18s
```

### node (k8s node machine)

설치 명령은 다음과 같습니다.
```
$ sudo apt-get update && sudo apt-get upgrade -y
### install Kubernetes
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
$ sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
$ sudo swapoff -a
$ sudo apt-get install -y kubeadm 
$ kubeadm version
```

master에 join 합니다.
```
$ sudo kubeadm join 192.168.1.40:6443 --token q62o8l.s93ppgg1nyvl66eg \
    --discovery-token-ca-cert-hash sha256:7ceafa6b28c940158115e564633be55c8022d638976d7a1353416ffeeb6462d4
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

### master (k8s master machine) 설치 확인하기

master에서 node가 정상적으로 join 되었는지 확인합니다. 
```
$ kubectl get nodes
NAME     STATUS     ROLES    AGE     VERSION
master   Ready      master   6m40s   v1.15.3
node01   NotReady   <none>   51s     v1.15.3
```