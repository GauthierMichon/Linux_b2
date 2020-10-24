#!/bin/bash

# Config du fichier host
echo "192.168.4.11  gitea.tp4.b2 gitea" >> /etc/hosts
echo "192.168.4.13  nginx.tp4.b2 nginx" >> /etc/hosts
echo "192.168.4.14  nfs.tp4.b2 nfs" >> /etc/hosts

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

yum -y install mariadb-server

echo "bind-address = 192.168.4.11" >> /etc/my.cnf

systemctl start mariadb.service
systemctl enable mariadb.service

# Config du gitea
mysql -h "localhost" "--user=root" "--password=" -e \
	"SET old_passwords=0;" -e \
	"CREATE USER 'gitea'@'192.168.4.12' IDENTIFIED BY 'gitea';" -e \
	"SET PASSWORD FOR 'gitea'@'192.168.4.12' = PASSWORD('gitea');" -e \
	"CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';" -e \
	"grant all privileges on giteadb.* to 'gitea'@'192.168.4.%' identified by 'gitea' with grant option;" -e \
	"FLUSH PRIVILEGES;"