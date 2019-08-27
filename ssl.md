### Docker private registry

---
docker private registry는 보안상 http를 지원하지않는다. 따라서 https를 사용해야 하며, https를 지원하기 위해서 전자서명 파일이 필요하다. 여기서는 openssl을 이용하여 전자서명을 생성해 보겠다.  
(유료는 비싸다.)    

#### 전자서명 파일 생성  
```
# Home 디렉토리에서 docker-registry 폴더를 생성하고 그 밑에 cert 라는 폴더를 생성하여 전자서명을 생성하도록 하겠습니다.
~$ cd ~
~$ mkdir -P docker-registry/cert
~$ cd docker-registry/cert
~/docker-registry/cert$ 
# 전자서명 파일을 생성하겠습니다. 
~/docker-registry/cert$ openssl genrsa -des3 -out server.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
.............................................................+++++
.....................+++++
e is 65537 (0x010001)
Enter pass phrase for server.key:
Verifying - Enter pass phrase for server.key:
~/docker-registry/cert$
#
# -------------------------------------------------------------------------------------------------------
#
~/docker-registry/cert$ openssl req -new -key server.key -out server.csr
Enter pass phrase for server.key:
Can't load /home/roy/.rnd into RNG
139679033291200:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/roy/.rnd
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: oiio.xyz  <==== 도메인
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:kstkmr2010
An optional company name []:
~/docker-registry/cert$
#
# -------------------------------------------------------------------------------------------------------
#
~/docker-registry/cert$ openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
Signature ok
subject=C = AU, ST = Some-State, O = Internet Widgits Pty Ltd, CN = oiio.xyz
Getting Private key
Enter pass phrase for server.key:
~/docker-registry/cert$
~/docker-registry/cert$ ls -al
total 20
drwxrwxr-x 2 roy roy 4096 Aug 25 08:30 .
drwxr-xr-x 6 roy roy 4096 Aug 25 08:23 ..
-rw-rw-r-- 1 roy roy 1176 Aug 25 08:30 server.crt
-rw-rw-r-- 1 roy roy 1021 Aug 25 08:27 server.csr
-rw------- 1 roy roy 1751 Aug 25 08:24 server.key
#
# -------------------------------------------------------------------------------------------------------
#
~/docker-registry/cert$ cp server.key server.key.origin
~/docker-registry/cert$ openssl rsa -in server.key.origin -out server.key
Enter pass phrase for server.key.origin:
writing RSA key
~/docker-registry/cert$

```

전자서명 파일 생성시 기입하게 되는 정보중
Common Name (eg, your name or your server’s hostname) []: oiio.xyz
해당정보를 반드시 registry에서 사용하게될 도메인 name명과 같아야한다.

#### 전자서명 시스템 업데이트
docker private registry에 로그인하려면 로그인하는 시스템에서 docker private registry를 구성할때 사용한 ssl server.crt 전자서명 시스템을 업데이트해야한다.  
docker private registry를 구축한 현재의 서버에서도 당연히 로그인을 할것이기에 update를 해준다.  
(remote client 에서 해당 docker private registry를 사용하려면 당연히 현재의 작업을 똑같이 수행햐주어야한다.)  
참고해야 할 점은 시스템에따라 전자서명 update하는 방식이 조금씩은 다르다는 점이다 .  

##### ubuntu
```
~/docker-registry/cert$ sudo cp ~/docker-registry/cert/server.crt /usr/share/ca-certificates/
~/docker-registry/cert$ sudo echo "server.crt" | sudo tee -a /etc/ca-certificates.conf > /dev/null
~/docker-registry/cert$ sudo update-ca-certificates
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
~/docker-registry/cert$ sudo service docker restart
```

#### Docker private registry login 설정
docker private registry에서 사용할 인증정보 (username과 password) 를 생성한다.  

username: roy  
password: 0000  

```
$ mkdir -p ~/docker-registry/auth
$ cd ~/docker-registry/auth
~/docker-registry/auth$ docker run \
  --entrypoint htpasswd \
  registry -Bbn roy 0000 > htpasswd
Unable to find image 'registry:latest' locally
latest: Pulling from library/registry
c87736221ed0: Pulling fs layer
1cc8e0bb44df: Pulling fs layer
54d33bcb37f5: Pulling fs layer
e8afc091c171: Pulling fs layer
b4541f6d3db6: Pulling fs layer
1cc8e0bb44df: Verifying Checksum
1cc8e0bb44df: Download complete
c87736221ed0: Verifying Checksum
c87736221ed0: Download complete
c87736221ed0: Pull complete
54d33bcb37f5: Verifying Checksum
54d33bcb37f5: Download complete
1cc8e0bb44df: Pull complete
54d33bcb37f5: Pull complete
e8afc091c171: Verifying Checksum
e8afc091c171: Download complete
b4541f6d3db6: Verifying Checksum
b4541f6d3db6: Download complete
e8afc091c171: Pull complete
b4541f6d3db6: Pull complete
Digest: sha256:8004747f1e8cd820a148fb7499d71a76d45ff66bac6a29129bfdbfdc0154d146
Status: Downloaded newer image for registry:latest
roy@oiio-build:~/docker-registry/auth$ ll
total 12
drwxrwxr-x 2 roy roy 4096 Aug 25 08:54 ./
drwxrwxr-x 4 roy roy 4096 Aug 25 08:52 ../
-rw-rw-r-- 1 roy roy   66 Aug 25 08:54 htpasswd
~/docker-registry/auth$
```

##### Docker private registry 실행
docker registry를 container로 실행시킵니다.    

주의할점  
-v ~/docker-registry/auth:/auth \  
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \  
-v ~/docker-registry/cert:/certs \  
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt \  
-e REGISTRY_HTTP_TLS_KEY=/certs/server.key \  
host os에 mount 될 경로를 정확히 적어주어야한다.  
 
```
$ mkdir -p ~/docker-registry/volume
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v ~/docker-registry/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/data \
  -v ~/docker-registry/volume:/data \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v ~/docker-registry/cert:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/server.key \
  registry
```

##### host 추가
이제 docker private registry에 login할 dns를 등록하자.  
docker private registry에 로그인시 일반 ip 정보로는 로그인할수없기에 이것또한 반드시 수행되어야할 작업이다.  
(remote client 해당 docker private registry를 사용하려면 당연히 현재의 작업을 똑같이 수행햐주어야한다.)  
```
$ vi /etc/hosts
111.111.111.223 oiio.xyz
```

##### Docker private registry login
```
```