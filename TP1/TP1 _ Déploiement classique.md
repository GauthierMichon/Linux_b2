# TP1 : Déploiement classique

## 0. Prérequis

#### Ajout d'un disque

Pour ajouter un deuxième disque, on va dans Virtual Box, sur notre VM.
On va dans configuration, Stockage. On ajoute un disque dans `Contrôleur : SATA`

![](https://i.imgur.com/fSFsS10.png)

On a mainteant notre deuxième disque.

#### Partitionner avec LVM

Pour repérer les disques à partitionner, on fait la commande : `lsblk`

```
[user@localhost ~]$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0    8G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    7G  0 part
  ├─centos-root 253:0    0  6.2G  0 lvm  /
  └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
sdb               8:16   0    5G  0 disk
sr0              11:0    1 1024M  0 rom
sr1              11:1    1 1024M  0 rom
```


On ajouter le disque `sdb`(celui que l'on a créer précédement) en tant que PV dans LVM, en utilisant la commande `sudo pvcreate /dev/sdb`.

```
[user@localhost ~]$ sudo pvcreate /dev/sdb
[sudo] password for user:
  Physical volume "/dev/sdb" successfully created.
```

On nous signal que le volume a bien été créé.
On le vérifie en faisant `sudo pvs`.

```
[user@localhost ~]$ sudo pvs
  PV         VG     Fmt  Attr PSize  PFree
  /dev/sda2  centos lvm2 a--  <7.00g    0
  /dev/sdb          lvm2 ---   5.00g 5.00g
```


On créer maintenant un Volume Group avec la commande `sudo vgcreate data /dev/sdb`

```
[user@localhost ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
```

On nous signal que le Groupe a bien été créé.
On le vérifie en faisant `sudo vgs`.


```
[user@localhost ~]$ sudo vgs
  VG     #PV #LV #SN Attr   VSize  VFree
  centos   1   2   0 wz--n- <7.00g     0
  data     1   0   0 wz--n- <5.00g <5.00g
```

On créer maintenant nos 2 LV avec la commande `lvcreate`.

La première que je nomme data1 : 

```
[user@localhost ~]$ sudo lvcreate -L 2G data -n data1
  Logical volume "data1" created.
```

La deuxième que je nomme data2 :
  
```
[user@localhost ~]$ sudo lvcreate -l 100%FREE data -n data2
  Logical volume "data2" created.
```

On vérifie que les 2 sont créer avec la commande `lvs`

```
[user@localhost ~]$ sudo lvs
  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root  centos -wi-ao----  <6.20g
  swap  centos -wi-ao---- 820.00m
  data1 data   -wi-a-----   2.00g
  data2 data   -wi-a-----  <3.00g
```

On formate nos partitions avec la commande `mkfs -t <FS> <PARTITION>`.

Première partition(data1) :

```
[user@localhost ~]$ sudo mkfs -t ext4 /dev/data/data1
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131072 inodes, 524288 blocks
26214 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=536870912
16 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

Deuxième partition(data2) :

```
[user@localhost ~]$ sudo mkfs -t ext4 /dev/data/data2
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
196608 inodes, 785408 blocks
39270 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=805306368
24 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

On monte nos partitions formaté avec la commande `mount`.

```
[user@localhost ~]$ sudo mount /dev/data/data1 /srv/site1
[user@localhost ~]$ sudo mount /dev/data/data2 /srv/site2
```

Pour vérifier, on fait la commande `mount`, puis `df -h`.

```
[user@localhost ~]$ df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/data-data1   2.0G  6.0M  1.8G   1% /srv/site1
/dev/mapper/data-data2   2.9G  9.0M  2.8G   1% /srv/site2
```

Nos partitions ont bien été monté sur /srv/data1 et /srv/data2.

On va définir un montage automatique au boot de la machine.

Pour cela on modifie le fichier /etc/fstab.

Pour vérifier, on fait la commande `mount -av`

```
[user@localhost ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
swap                     : ignored
/srv/site1               : already mounted
/srv/site2               : already mounted

On a bien /srv/site1 et /srv/site2 de montées.
```

#### un accès internet

Pour cela, il nous faut une carte NAT et une route par default.
La carte NAT s'ajoute dans virtual box, dans Configuration -> Réseaux 

![](https://i.imgur.com/S7vH2jz.png)

Pour la route par default, on fait un `ip r s` pour vérifier qu'elle est présente.

```
[user@localhost ~]$ ip r s
default via 10.0.2.2 dev enp0s3 proto dhcp metric 100
```

On peut vérifier en faisant un `curl`.

```
[user@VM1 ~]$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

Ici on obtenu un résultat, on a donc bien internet sur nos machines.



#### un accès internet à un réseau local.

Pour cela, il nous faut une carte réseau privé hôte, et que les ip des 2 machines soit dans le même réseau privé(qu'ils aient des ip similaires, sauf le dernier nombre.).

Pour vérifier la route, on fait `ip r s`

```
[user@localhost ~]$ ip r s
default via 192.168.1.254 dev enp0s8 proto static metric 101
```

Puis pour configurer l'ip des machines, on fait `sudo vim /etc/sysconfig/network-scripts/ifcfg-enp0s8`.

```
TYPE=Ethernet
BOOTPROTO=dhcp
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=192.168.1.11
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
```

On essaie maintenant de ping la deuxième machine (elle a la même configuration, sauf l'ip qui est 192.168.1.12).

```
[user@localhost ~]$ ping 192.168.1.12
PING 192.168.1.12 (192.168.1.12) 56(84) bytes of data.
64 bytes from 192.168.1.12: icmp_seq=1 ttl=64 time=4.10 ms
64 bytes from 192.168.1.12: icmp_seq=2 ttl=64 time=0.750 ms
^C
--- 192.168.1.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.750/2.425/4.100/1.675 ms
```

Les machines peuvent se joindre.


#### Donner un nom aux machines

Pour changer le nom des machines, il faut modifier le fichier `/etc/hostname`.
On fait donc un `[user@localhost ~]$ sudo vim /etc/hostname`. Puis on met le nom souhaité. 

Dans notre cas la première machine s'appelle `node1`, et la deuxième `node2`.

On relance les machines pour que le changement soit effectif.

On a bien `[user@node1 ~]$` et plus `[user@localhost ~]$`. Le nom de la machine a été changer avec succès.


#### Les machines doivent pouvoir se joindre par leurs noms respectifs

Pour cela, il faut modifier le fichier `/etc/hosts`
On fait donc un `sudo vim /etc/hosts`. Puis on met la ligne correspondante. On rajoute la ligne `192.168.1.12  node2.tp1.b2` dans le fichier de la première machine.

On tente maitenant de ping la deuxième machine en utilisant son nom.

```
[user@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (192.168.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=1 ttl=64 time=0.665 ms
64 bytes from node2.tp1.b2 (192.168.1.12): icmp_seq=2 ttl=64 time=0.758 ms
^C
--- node2.tp1.b2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.665/0.711/0.758/0.053 ms
```

La première machine arrive à joindre la seconde en utilisant son nom.
On fait maintenant la même config pour la deuxième machine.


#### Créer un utilisateur administrateur est créé sur les deux machines

Pour cela, on fait un `useradd` puis on modifie visudo(conf sudo).

`[user@node1 ~]$ sudo useradd admin`

On lui donne un mot de passe avec `[user@node1 ~]$ sudo passwd admin`.

On lui donne maintenant les droits root en faisant `[user@node1 ~]$ sudo visudo`.

Dans ce fichier, on rajoute la ligne `admin   ALL=(ALL)       ALL`.

Pour vérifier ses droits, on change d'utilisateur pour admin avec la commande `su admin` et on fait une commande qui nécessite d'être en root.


#### Pare-feu

Pour lister les ports ouverts, on fait `sudo firewall-cmd --list-all`.

```
[user@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: dhcpv6-client ssh
  ports: 7777/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Je n'ai qu'un port ouvert, le 7777 qui me sert pour ma connexion ssh.


## I. Setup serveur Web


On commence par installer nginx. Pour cela, il faut tout d'abords faire un update `sudo yum update`. puis `sudo yum install epel-release`. Et enfin `sudo yum install nginx`.

```
Installed:
  nginx.x86_64 1:1.16.1-1.el7

Dependency Installed:
  centos-indexhtml.noarch 0:7-9.el7.centos                       dejavu-fonts-common.noarch 0:2.33-6.el7
  dejavu-sans-fonts.noarch 0:2.33-6.el7                          fontconfig.x86_64 0:2.13.0-4.3.el7
  fontpackages-filesystem.noarch 0:1.44-8.el7                    gd.x86_64 0:2.0.35-26.el7
  gperftools-libs.x86_64 0:2.6.1-1.el7                           libX11.x86_64 0:1.6.7-2.el7
  libX11-common.noarch 0:1.6.7-2.el7                             libXau.x86_64 0:1.0.8-2.1.el7
  libXpm.x86_64 0:3.5.12-1.el7                                   libjpeg-turbo.x86_64 0:1.2.90-8.el7
  libxcb.x86_64 0:1.13-1.el7                                     libxslt.x86_64 0:1.1.28-5.el7
  nginx-all-modules.noarch 1:1.16.1-1.el7                        nginx-filesystem.noarch 1:1.16.1-1.el7
  nginx-mod-http-image-filter.x86_64 1:1.16.1-1.el7              nginx-mod-http-perl.x86_64 1:1.16.1-1.el7
  nginx-mod-http-xslt-filter.x86_64 1:1.16.1-1.el7               nginx-mod-mail.x86_64 1:1.16.1-1.el7
  nginx-mod-stream.x86_64 1:1.16.1-1.el7

Complete!
```

nginx a bien été intallé.

On start nginx

`[user@node1 ~]$ sudo systemctl start nginx`



On crée les index.html en faisant des `touch`

```
[user@node1 ~]$ sudo touch /srv/site1/index.html
[user@node1 ~]$ sudo touch /srv/site2/index.html
```


On leur met un contenu

```
[user@node1 ~]$ sudo vim /srv/site1/index.html
[user@node1 ~]$ sudo vim /srv/site2/index.html
```
Personnellemnt j'ai écrit : 
 -Ceci est l'index de mon premier site
 -Ceci est l'index de mon deuxième site


On met les permissions : 

```
[user@node1 ~]$ sudo chmod -R 755 /srv/site1
[user@node1 ~]$ sudo chmod -R 755 /srv/site2
```


On attribut ces dossiers à un utilisateur et à un groupe : 

```
[user@node1 ~]$ sudo chown -R user:user /srv/site1
[user@node1 ~]$ sudo chown -R user:user /srv/site2
```


On vérifie que nos changement on été effectué

```
[user@node1 ~]$ ls -al /srv/site1/
total 24
drwxr-xr-x. 3 user user  4096 Sep 27 10:15 .
drwxr-xr-x. 4 root root    32 Sep 23 19:51 ..
-rwxr-xr-x. 1 user user    33 Sep 27 10:15 index.html
drwxr-xr-x. 2 user user 16384 Sep 23 19:50 lost+found
```

Le propriétaire est user.
Le groupe propiétaire est user.
User peut lire, écrire et exécuter dans le fichier. Les autres ne peuvent que le lire et exécuter.



On ouvre les services

```
[user@node1 ~]$ sudo firewall-cmd --zone=public --add-service=http
success
[user@node1 ~]$ sudo firewall-cmd --zone=public --add-service=https
success
```

On génère notre certificat pour pouvoir utiliser https.

```
[user@node1 ~]sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
Generating a 2048 bit RSA private key
..+++
......+++
writing new private key to 'server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:
State or Province Name (full name) []:
Locality Name (eg, city) [Default City]:
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:node1.tp1.b2
Email Address []:
```

On move les deux fichier créer dans /etc/nginx.
```
[user@node1 ~]$ sudo mv server.crt /etc/nginx
[user@node1 ~]$ sudo mv server.key /etc/nginx
```

Puis on configure nginx avec la commande `sudo vim /etc/nginx/nginx.conf`.
Dedans j'ai ce code : 

```
[user@node1 ~]$ cat /etc/nginx/nginx.conf
worker_processes 1;
error_log nginx_error.log;
events {
    worker_connections 1024;
}

http {
     server {
        listen 80;

        server_name node1.tp1.b2;

        location / {
                return 301 /site1;
        }

        location /site1 {
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }
}

server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;

        location / {
            return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
    }
}
```

On essaie de se connecter aux 2 sites avec node2.

```
[user@node2 ~]$ curl -L node1.tp1.b2/site1
Ceci est l'index du premier site
[user@node2 ~]$ curl -L node1.tp1.b2/site2
Ceci est l'index du site 2
```

Puis on essaie en https.

```
[user@node2 ~]$ curl -kL https://node1.tp1.b2/site1
Ceci est l'index du premier site
[user@node2 ~]$ curl -kL https://node1.tp1.b2/site2
Ceci est l'index du site 2
```

node2 peut joindre les deux site en http et https.


## II. Script de sauvegarde

On crée le fichier du script en faisant `touch tp1_backup.sh`.

On crée un dossier sauvegarde en faisant `mkdir sauvegarde`.

On crée ensuite les deux dossiers site1 et site2 dans sauvegarde en faisant `mkdir sauvegarde/site1` et `mkdir sauvegarde/site2`.

On crée l'utilisateur backup en faisant la commande `adduser backup`.

On rempli ensuite le fichier tp1_backup.sh avec la commande `vim` (Le fichier est sur le git).


On installe crontab.

`[user@node1 ~]$ sudo yum install crontabs`

On start crontab

`sudo systemctl start crond.service`

On le configure pour exécuter les sauvegardes toutes les heures. On fait la commande `crontab -e`.

Dedans on met : 
```
0 * * * * backup tp1.backup.sh /srv/site1                                   0 * * * * backup tp1.backup.sh /srv/site2
```

## III. Monitoring, alerting

On intalle Netdata avec la commande `bash <(curl -Ss https://my-netdata.io/kickstart.sh)`

On ouvre le port.
`[user@node1 ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent`

On crée un webhook dans un serveur discord. Il enverra les messages d'alerte.

![](https://i.imgur.com/q0wybIp.png)


On modifie le fichier `/etc/netdata/edit-config health_alarm_notify.conf`, on met dans la ligne `DISCORD_WEBHOOK_URL=""`, le lien de notre WebHook.
J'obtiens : `DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/760131802974257172/AwU3v6x04oTd0QyBiVqXCtNsE_ieJE_BJ6Ig6GDee36NKjjG7O8iPu45zFqOtgPKkSpI"`

Et enfin on modifie le fichier conf de nginx.

```
worker_processes 1;
error_log nginx_error.log;
events {
    worker_connections 1024;
}

http {
     server {
        listen 80;

        server_name node1.tp1.b2;

        location / {
                return 301 /site1;
        }

        location /site1 {
                alias /srv/site1;
        }

        location /site2 {
                alias /srv/site2;
        }
}

server {
        listen 443 ssl;

        server_name node1.tp1.b2;
        ssl_certificate server.crt;
        ssl_certificate_key server.key;

        location / {
            return 301 /site1;
        }

        location /site1 {
            alias /srv/site1;
        }
        location /site2 {
            alias /srv/site2;
        }
        location ~ /netdata/(?<ndpath>.*) {
            proxy_redirect off;
            proxy_set_header Host $host;

            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_pass_request_headers on;
            proxy_set_header Connection "keep-alive";
            proxy_store off;
            proxy_pass http://netdata/$ndpath$is_args$args;

            gzip on;
            gzip_proxied any;
            gzip_types *;
        }
    }
}
```

Et c'est terminé.