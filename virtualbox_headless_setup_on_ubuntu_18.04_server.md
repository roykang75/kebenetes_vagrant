## Ubuntu 18.04 Server에 Virtualbox 5.2 headless 버전 설치하기

### ubuntu 18.04 server를 설치합니다.  
### ubuntu server를 업데이트 합니다.  
```
$ sudo apt-get update && sudo apt-get upgrade -y
```

### VirtualBox를 다운받기 위한 key 다운로드 및 추가
```
$ wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
$ wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
```

### Virtualbox download repo 추가 및 5.2 설치
```
$ echo 'deb https://download.virtualbox.org/virtualbox/debian bionic contrib' | sudo tee -a /etc/apt/sources.list
$ sudo apt-get update
$ sudo apt-get install virtualbox-5.2
```

### phpVirtualbox 다운로드 및 설치
```
$ sudo apt-get install -y apache2 php php-mysql libapache2-mod-php php-soap php-xml unzip vagrant
$ wget https://github.com/phpvirtualbox/phpvirtualbox/archive/5.2-1.zip
$ unzip 5.2-1.zip
```

### phpvirtualbox 설정
```
$ sudo mv phpvirtualbox-5.2-1/ /var/www/html/phpvirtualbox
$ sudo chmod 777 /var/www/html/phpvirtualbox/
$ sudo cp /var/www/html/phpvirtualbox/config.php-example /var/www/html/phpvirtualbox/config.php
```

### phpVirtualbox에 사용자 등록하기 (phpVirtualbox를 설치한 ubuntu 계정 사용)
```
$ sudo vim /var/www/html/phpvirtualbox/config.php
var $username = 'sk';
var $password = 'ubuntu';
```

### web사용 계정 등록
```
$ sudo vim /etc/default/virtualbox
VBOXWEB_USER=sk
```

### 서비스 재시작
```
sudo systemctl restart vboxweb-service
sudo systemctl restart vboxdrv
sudo systemctl restart apache2
```

### 사이트 접속
```
http://ubuntuServer_IP/phpvirtualbox
```

username/password는 아래 계정을 사용한다.
```
ID: admin
Password: admin
```

### 내부 네트워크를 위한 가상 디바이스 추가
File > Preferences > Network

![](/assets/vbox_network_1.png)

Network를 선택한 후, [Host-only Networks] 탭을 선택합니다.  
![](/assets/vbox_network_2.png)

오른쪽의 [+] 버튼을 클릭합니다. "vboxnet0"가 생성되는 것을 확인 할 수 있습니다.  
![](/assets/vbox_network_3.png)

vboxnet0에 대한 자세한 정보를 보기 위해서는 옆에 [Edit host-only networks] 아이콘을 클릭하면 됩니다.
![](/assets/vbox_network_4.png)

표시되는 정보의 의미는 다음가 같습니다.  
IPv4 Address: 192.168.56.1  
IPv4 Network Mask: 255.255.255.0  

Geteway IP address가 192.168.56.1 인 가상의 장치(vboxnet0)가 있으며, subnet mask는 255.255.255.0 이다.  
이는 192.168.56.2 ~ 192.168.56.254 까지 IP를 할당받을 수 있는 가상의 네트워크가 만들어 졌다는 의미입니다.  

작업이 완료되었으면 [OK]버튼을 클릭하여 창을 닫습니다.  

이제 virtualbox 5.2 headless version 설치가 완료되었습니다.  

