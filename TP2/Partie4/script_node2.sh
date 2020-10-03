#!/bin/sh

echo "192.168.2.21 node1.tp2.b2" >> /etc/hosts

firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=https