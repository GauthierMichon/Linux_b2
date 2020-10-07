#!/bin/bash

yum -y install vim
yum -y install epel-realse
yum -y install nginx
yum -y install python3

touch web.service /etc/systemd/system/

touch /usr/local/bin/start.sh
touch /usr/local/bin/stop.sh

chmod +x /usr/local/bin/start.sh
chmod +x /usr/local/bin/stop.sh

mkdir /sauvegarde/
mkdir /sauvegarde/site1/
mkdir /srv/
mkdir /srv/site1/
touch /srv/site1/index.html

touch pre_backup.sh
touch backup.sh
touch after_backup.sh
chmod +x pre_backup.sh
chmod +x backup.sh
chmod +x after_backup.sh

touch /etc/systemd/system/backup.service
touch /usr/lib/systemd/system/backup.timer