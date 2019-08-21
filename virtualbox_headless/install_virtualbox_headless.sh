#!bin/bash

# ubuntu server를 업데이트 합니다.
sudo apt-get update && sudo apt-get upgrade -y

# VirtualBox를 다운받기 위한 key 다운로드 및 추가
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

# Virtualbox download repo 추가 및 5.2 설치
echo 'deb https://download.virtualbox.org/virtualbox/debian bionic contrib' | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install virtualbox-5.2

# phpVirtualbox 다운로드 및 설치
sudo apt-get install -y apache2 php php-mysql libapache2-mod-php php-soap php-xml unzip vagrant
wget https://github.com/phpvirtualbox/phpvirtualbox/archive/5.2-1.zip
unzip 5.2-1.zip

# phpvirtualbox 설정
sudo mv phpvirtualbox-5.2-1/ /var/www/html/phpvirtualbox
sudo chmod 777 /var/www/html/phpvirtualbox/
sudo cp /var/www/html/phpvirtualbox/config.php-example /var/www/html/phpvirtualbox/config.php

