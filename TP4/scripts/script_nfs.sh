#!/bin/bash

# Config du fichier host
echo "192.168.4.11  gitea.tp4.b2 gitea" >> /etc/hosts
echo "192.168.4.12  mariadb.tp4.b2 mariadb" >> /etc/hosts
echo "192.168.4.13  nginx.tp4.b2 nginx" >> /etc/hosts

systemctl start nfs-server rpcbind
systemctl enable nfs-server rpcbind

mkdir /nfsbackup/

mkdir /nfsbackup/gitea/
mkdir /nfsbackup/mariadb/
mkdir /nfsbackup/nginx/

chmod 777 /nfsbackup/

echo -e "/nfsbackup/gitea/   192.168.4.11(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsbackup/mariadb/   192.168.4.12(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/nfsbackup/nginx/   192.168.4.13(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)" > /etc/exports


# On active les services nécessaires au bon fonctionnement de nfs
firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-service nfs
firewall-cmd --reload