## vagrant를 이용하여 ubuntu 18.04 server에 kubernetes 설치하기 :no_mouth:

* 테스트 환경  
> vagrant: Vagrant 2.0.2  
> virtualbox: virtualbox 5.2  
> phpVirtualbox: phpvirtualbox-5.2-1  
> os: ubuntu 18.04 server  
> docker: docker-ce=18.06.2~ce~3-0~ubuntu  


### 소스 복사하기
```
roy@ubuntu:~$ git clone https://github.com/roykang75/kubernetes_vagrant.git
```

### vagrant를 이용하여 가상머신 만들기  
vagrant script에 따라 가상머신이 만들어집니다.  
(가상 머신 생성 및 provision shell script 실행 시간은 네트워크 상황에 따라 30분에서 1시간까지 소요될 수 있습니다.)
```
roy@ubuntu:~$ cd ./kubernetes_vagrant/vagrant
roy@ubuntu:~/kubernetes_vagrant/vagrant$ vagrant up
```

생성이 완료되면 아래 명령을 사용하여 생성된 가상 머신을 확인 할 수 있습니다.  
```
roy@ubuntu:~/kubernetes_vagrant/vagrant$ vagrant status
Current machine states:

k8s-master                running (virtualbox)
k8s-worker-node1          running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

### 가상 머신에 접속하기  
vagrant로 생성한 가상 머신에 ssh로 접속하기 위해서는 ip로 접속하는 방법과 vagrant를 이용하여 접속하는 방법이 있습니다.  
ip로 접속하는 방법은 일반적인 방법과 동일합니다.  
여기서는 vagrant를 이용하여 접속하겠습니다.  
위의 가상머신 리스트 중 k8s-master에 접속하기 위해서는 아래와 같이 입력합니다.  
```
roy@ubuntu:~/kubernetes_vagrant/vagrant$ vagrant ssh k8s-master
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 4.15.0-55-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

vagrant@k8s-master:~$
```

### k8s-master에 kubernetes master 설치하기

```
vagrant@k8s-master:~$ bash install-kube-master.sh
...........
...........
...........
...........
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

kubeadm join 192.168.1.100:6443 --token lkr52g.ishyph4lma7jhfwd \
    --discovery-token-ca-cert-hash sha256:743585a4491d6f5caefd546e07e1f6792aec174873185174c43bc5a7f7cb3eed 
================================================================================
================================================================================
 Weave net installation
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.extensions/weave-net created
================================================================================
 kubectl get nodes
NAME         STATUS     ROLES    AGE   VERSION
k8s-master   NotReady   master   47s   v1.15.2
================================================================================
 sudo kubectl get pods --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-llg4w             1/1     Running   0          88s
kube-system   coredns-5c98db65d4-ttprx             1/1     Running   0          88s
kube-system   etcd-k8s-master                      1/1     Running   0          27s
kube-system   kube-apiserver-k8s-master            1/1     Running   0          40s
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          39s
kube-system   kube-proxy-q6xbs                     1/1     Running   0          88s
kube-system   kube-scheduler-k8s-master            1/1     Running   0          43s
kube-system   weave-net-qbgpn                      2/2     Running   0          81s
vagrant@k8s-master:~$
```

node 들의 정보를 읽어보겠습니다.  
```
vagrant@k8s-master:~$ kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   3m48s   v1.15.2
vagrant@k8s-master:~$
```
현재는 1개의 node만 있습니다.  


### k8s-worker-node1에 kubernetes node 설치하기
```
vagrant@k8s-worker-node1:~$ bash install-kube-slave.sh
...........
...........
...........
...........
kubeadm version: &version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.2", GitCommit:"f6278300bebbb750328ac16ee6dd3aa7d3549568", GitTreeState:"clean", BuildDate:"2019-08-05T09:20:51Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

### master에 join하기
```
vagrant@k8s-worker-node1:~$ sudo kubeadm join 192.168.1.100:6443 --token lkr52g.ishyph4lma7jhfwd --discovery-token-ca-cert-hash sha256:743585a4491d6f5caefd546e07e1f6792aec174873185174c43bc5a7f7cb3eed 
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

vagrant@k8s-worker-node1:~$
```

### node 정보 보기 (k8s-master)
```
vagrant@k8s-master:~$ kubectl get nodes
NAME               STATUS   ROLES    AGE     VERSION
k8s-master         Ready    master   18m     v1.15.2
k8s-worker-node1   Ready    <none>   3m44s   v1.15.2
vagrant@k8s-master:~$
```
두 개의 node를 확인할 수 있습니다.  

