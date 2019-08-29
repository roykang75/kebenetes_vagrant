### Setup Kubernetes Dashboard

---
Kubernetes Dashboard 설치 방법에 대해 설명합니다.

참고사이트: https://kubernetes.io/ko/docs/tasks/access-application-cluster/web-ui-dashboard/

### Kubernetes Dashboard 설치하기

Service 계정과 ClusterRoleBinding 를 만듭니다.  

```
$ $ cat <<EOF | kubectl create -f -
> apiVersion: v1
> kind: ServiceAccount
> metadata:
>   name: admin-user
>   namespace: kube-system
> EOF
serviceaccount/admin-user created

$ $ cat <<EOF | kubectl create -f -
> apiVersion: rbac.authorization.k8s.io/v1
> kind: ClusterRoleBinding
> metadata:
>   name: admin-user
> roleRef:
>   apiGroup: rbac.authorization.k8s.io
>   kind: ClusterRole
>   name: cluster-admin
> subjects:
> - kind: ServiceAccount
>   name: admin-user
>   namespace: kube-system
> EOF
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
```

admin-user token을 확인합니다.  

```
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
Name:         admin-user-token-dmqr5
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 54719554-f15d-4ad9-98a6-142c39eb21df

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWRtcXI1Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI1NDcxOTU1NC1mMTVkLTRhZDktOThhNi0xNDJjMzllYjIxZGYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.GZsO45RSjc-o5d4CuPWNHaeDaaw85eb7tYkKV7KM552pEl8x56ym1UbRbS3DCoYmgN9NK9gJyCS9yksiiK2z4cIa-xKofQGrmtQMQBX-1mFwebQ93p_xs8ZYx9t_o2dVkMNZgN2qYobQKJC0wTTG-FjIxlOwe_fN85JlCM-Fq741UApFKcfL9BFscgWnlb2OtE_i9XLbt-rxCvaQknAr8jhQAr3YjhvokHMHkQB3CSbhlrxhOgmNXEmFLvZs7T49aPAeZ1uyVuxkIiRM6Ec1jvhgTSBO3cT75xpUZKLt92cSr-bVlnZ4gx-JfiNm2cwlDgBOZfJ77OOQ01Zj8WO_fA
```

Kubernetes dashboard를 사용하기 위해 dashboard를 설치합니다.  
설치 명령은 아래와 같습니다.  

```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/kubernetes-metrics-scraper created
```


### API Server를 이용하여 dashboard에 접속하기

브라우져를 사용하여 아래 url로 접속합니다.
```
### url
https://<master-ip>:<apiserver-port>/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
```
https://192.168.1.40:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

결과는 아래와 같습니다.  
```
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {
    
  },
  "status": "Failure",
  "message": "services \"https:kubernetes-dashboard:\" is forbidden: User \"system:anonymous\" cannot get resource \"services/proxy\" in API group \"\" in the namespace \"kube-system\"",
  "reason": "Forbidden",
  "details": {
    "name": "https:kubernetes-dashboard:",
    "kind": "services"
  },
  "code": 403
}
```

"reason": "Forbidden" 으로 보아 인증에 문제가 있어 보입니다.  

### 인증서 만들기

master에서 아래 명령을 실행합니다. 패스워드 입력 문구가 뜨면 패스워드를 입력하고 이를 기억합니다.  
```
$ mkdir -P ~/work/cert
$ cd ~/work/cert
$ grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt
$ grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key
$ openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-admin"
Enter Export Password:
Verifying - Enter Export Password:

### 인증서가 정상적으로 생성되었는지 확인합니다. 
$ ls -al
total 20
drwxrwxr-x 2 roy roy 4096 Aug 29 14:48 ./
drwxrwxr-x 3 roy roy 4096 Aug 29 14:45 ../
-rw-rw-r-- 1 roy roy 1082 Aug 29 14:47 kubecfg.crt
-rw-rw-r-- 1 roy roy 1679 Aug 29 14:47 kubecfg.key
-rw------- 1 roy roy 2454 Aug 29 14:48 kubecfg.p12   <==== 요 파일이 중요합니다.

### kubernetes pki 를 확인합니다.
$ ls -al /etc/kubernetes/pki/
total 68
drwxr-xr-x 3 root root 4096 Aug 29 13:20 .
drwxr-xr-x 4 root root 4096 Aug 29 13:20 ..
-rw-r--r-- 1 root root 1216 Aug 29 13:19 apiserver.crt
-rw-r--r-- 1 root root 1090 Aug 29 13:20 apiserver-etcd-client.crt
-rw------- 1 root root 1679 Aug 29 13:20 apiserver-etcd-client.key
-rw------- 1 root root 1675 Aug 29 13:19 apiserver.key
-rw-r--r-- 1 root root 1099 Aug 29 13:19 apiserver-kubelet-client.crt
-rw------- 1 root root 1675 Aug 29 13:19 apiserver-kubelet-client.key
-rw-r--r-- 1 root root 1025 Aug 29 13:19 ca.crt    <==== 요 파일이 중요합니다.
-rw------- 1 root root 1675 Aug 29 13:19 ca.key
drwxr-xr-x 2 root root 4096 Aug 29 13:20 etcd
-rw-r--r-- 1 root root 1038 Aug 29 13:19 front-proxy-ca.crt
-rw------- 1 root root 1675 Aug 29 13:19 front-proxy-ca.key
-rw-r--r-- 1 root root 1058 Aug 29 13:20 front-proxy-client.crt
-rw------- 1 root root 1675 Aug 29 13:20 front-proxy-client.key
-rw------- 1 root root 1679 Aug 29 13:20 sa.key
-rw------- 1 root root  451 Aug 29 13:20 sa.pub
```

위의 두 개의 파일이 중요합니다.  

인증서 처리는 client의 OS 환경에 따라 명령이 달라집니다.  

#### Windows 10  

[인터넷 익스플로러, 크롬, 엣지 브라우저 등에서 사용하기 위한 설정]  

***사용 터미널은 cmder의 cmd를 사용하였습니다.***  

Windows PC의 d:\utils\kubernetes 폴더에 ca.crt와 kubecfg.p12 파일을 scp 명령을 사용하여 복사합니다.

scp 사용방법: https://zetawiki.com/wiki/%EB%A6%AC%EB%88%85%EC%8A%A4_scp_%EC%82%AC%EC%9A%A9%EB%B2%95

```
c:\> scp roy@192.168.1.40:/etc/kubernetes/pki/ca.crt d:\utils\Kubernetes
roy@192.168.1.40's password:
ca.crt                                                                                                                                                                                                      100% 1025   332.2KB/s   00:00

c:\> scp roy@192.168.1.40:/home/roy/work/cert/kubecfg.p12 d:\utils\Kubernetes
roy@192.168.1.40's password:
kubecfg.p12

c:\> dir d:\utils\kubernetes
 D 드라이브의 볼륨에는 이름이 없습니다.
 볼륨 일련 번호: EC25-1DAF

 d:\utils\kubernetes 디렉터리

2019-08-29  오후 11:58    <DIR>          .
2019-08-29  오후 11:58    <DIR>          ..
2019-08-29  오후 11:58             1,025 ca.crt
               1개 파일               1,025 바이트
               2개 디렉터리  927,622,410,240 바이트 남음

```

Window certutil.exe 명령을 사용하여 인증서를 등록합니다.

```
### ca.crt 를 등록합니다.
d:\> certutil.exe -addstore "Root" d:\utils\kubernetes\ca.crt
Root "신뢰할 수 있는 루트 인증 기관"
서명이 공개 키와 일치합니다.
"kubernetes" 인증서가 저장소에 추가되었습니다.
CertUtil: -addstore 명령이 성공적으로 완료되었습니다.

### kubecfg.p12 를 등록합니다.
d:\> certutil.exe -p {password} -user -importPFX d:\utils\Kubernetes\kubecfg.p12
"kubernetes-admin" 인증서가 저장소에 추가되었습니다.
```

아래와 윈도우 창이 나타나면 [확인]을 클릭합니다.   

![](/assets/cert.png)

아래와 같은 메시지가 나타나면 정상적으로 인증서가 등록된 것입니다.  

```
d:\> certutil.exe -p kstkmr2010 -user -importPFX d:\utils\Kubernetes\kubecfg.p12
"kubernetes-admin" 인증서가 저장소에 추가되었습니다.

CertUtil: -importPFX 명령이 성공적으로 완료되었습니다.
```

시스템을 재부팅합니다.  

#### Linux

[크롬 브라우저 등에서 사용하기 위한 설정]  

```
$ scp roy@192.168.1.40:/etc/kubernetes/pki/ca.crt $HOME/work/kubernetes/cert
roy@192.168.1.40's password: 
ca.crt                             100% 1025     1.0KB/s   00:00
$ scp roy@192.168.1.40:/home/roy/work/cert/kubecfg.p12 $HOME/work/kubernetes/cert
roy@192.168.1.40's password: 
kubecfg.p12                        100% 2454     2.4KB/s   00:00
```

먼저 $HOME 에 .pki/nssdb 폴더가 있는지 확인합니다.  
그리고 인증서 등록을 위해서 certutil 과 pk12util 이 설치되어 있는지도 확인합니다.  
없다면, apt-get 이나 yum 을 통해 먼저 설치를 합니다.  

```
$ certutil
프로그램 'certutil'을(를) 설치하지 않습니다. 다음을 입력해 설치할 수 있습니다:
sudo apt install libnss3-tools
$ pk12util
프로그램 'pk12util'을(를) 설치하지 않습니다. 다음을 입력해 설치할 수 있습니다:
sudo apt install libnss3-tools

### 인증에 필요한 software를 설치합니다.
$ sudo apt install libnss3-tools
```

모든 브라우저를 닫습니다. ca 파일을 설치합니다.  
```
$ certutil -A \
  -n "Kubernetes" \
  -t "TC,," \
  -d sql:$HOME/.pki/nssdb \
  -i $HOME/work/kubernetes/cert/ca.crt
```

kubecfg.12 파일도 추가해 줍니다. {password} 부분에는 p12 파일을 만들때, 입력했던 비밀번호를 넣어 줍니다.  
```
$ pk12util -i $HOME/work/kubernetes/cert/kubecfg.p12 \
  -d sql:$HOME/.pki/nssdb \
  -W {password}
```

시스템을 재부팅합니다.   


### 브라우져로 접속하기

브라우져를 사용하여 아래 url을 접속합니다.
```
https://192.168.1.40:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default 
```

아래와 같은 창이 나타나면 [확인]을 클릭합니다.  

![](/assets/chrome_cert.png)

아래는 dasbboard login 화면입니다.  

![](/assets/kube_dashboard_login.png)

위에서 확인한 admin-user token 값을 이용하여 로그인합니다.  

![](/assets/kube_dashboard_login_token.png)

로그인이 되면 아래와 같은 화면이 나타납니다.  

![](/assets/kube_dashboard_view.png)