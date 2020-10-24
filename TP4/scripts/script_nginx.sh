#!/bin/bash

# Config du fichier host
echo "192.168.4.11  gitea.tp4.b2 gitea" >> /etc/hosts
echo "192.168.4.12  mariadb.tp4.b2 mariadb" >> /etc/hosts
echo "192.168.4.14  nfs.tp4.b2 nfs" >> /etc/hosts

yum -y install epel-release
yum -y install nginx

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload


echo "
worker_processes auto;
error_log /var/log/nginx/error.log;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        server_name gitea;
        location / {
                proxy_pass http://192.168.4.11:3000;
        }
    }
}" > /etc/nginx/nginx.conf

sudo systemctl enable nginx
sudo systemctl start nginx
