# README

## Quelques infos et commandes à faire

#### Quelques infos sur le git

Dans le dossier scripts/ du git, vous trouverez le script exécuter par le vagrantfile au démarrage de la machine.

Dans le dossier systemd/units/ du git, vous trouverez les fichiers d'unité systemd.

Dans le dossier scripts_tp/ du git, vous trouverez les scripts qui sont exécutés pendant le TP.


#### Quelques commandes à effectué avant de commencer le TP

Avant tout il faut désactiver selinux.
On fait un `sudo setenforce 0`.
Ensuite, on change le fichier `/etc/selinux/config` pour qu'il ressemble à ça : 
```
[vagrant@node1 ~]$ cat /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

Ensuite, on active le firewall : `sudo firewalld`
On active le firewall a chaque démarrage : `sudo systemctl enable firewalld`

## I. Services systemd

#### 1. Intro

###### Utilisez la ligne de commande pour sortir les infos suivantes : 

- afficher le nombre de services systemd dispos sur la machine
```
[vagrant@node1 ~]$ systemctl list-units --type=service | grep "loaded units" | cut -c-3
41
```

- afficher le nombre de services systemd actifs et en cours d'exécution ("running") sur la machine
```
[vagrant@node1 ~]$ systemctl list-units --type=service --state=running | grep "loaded units" | cut -c-3
18
```

- afficher le nombre de services systemd qui ont échoué ("failed") ou qui sont inactifs ("exited") sur la machine
```
[vagrant@node1 ~]$ systemctl list-units --type=service --state=failed,exited | grep "loaded units" | cut -c-3
23
```

- afficher la liste des services systemd qui démarrent automatiquement au boot ("enabled")
```
[vagrant@node1 ~]$ systemctl list-unit-files --type=service | grep enabled
auditd.service                              enabled
autovt@.service                             enabled
chronyd.service                             enabled
crond.service                               enabled
dbus-org.fedoraproject.FirewallD1.service   enabled
dbus-org.freedesktop.NetworkManager.service enabled
dbus-org.freedesktop.nm-dispatcher.service  enabled
dbus-org.freedesktop.timedate1.service      enabled
firewalld.service                           enabled
getty@.service                              enabled
import-state.service                        enabled
irqbalance.service                          enabled
kdump.service                               enabled
loadmodules.service                         enabled
NetworkManager-dispatcher.service           enabled
NetworkManager-wait-online.service          enabled
NetworkManager.service                      enabled
nfs-convert.service                         enabled
nis-domainname.service                      enabled
rngd.service                                enabled
rpcbind.service                             enabled
rsyslog.service                             enabled
selinux-autorelabel-mark.service            enabled
sshd.service                                enabled
sssd.service                                enabled
syslog.service                              enabled
timedatex.service                           enabled
tuned.service                               enabled
vgauthd.service                             enabled
vmtoolsd.service                            enabled
```



#### 2. Analyse d'un service

###### Etudiez le service nginx.service


Déterminer le path de l'unité nginx.service : 

```
[vagrant@node1 ~]$ systemctl status nginx.service
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```

Le path de l'unité nginx.service est :  `/usr/lib/systemd/system/nginx.service`.



afficher son contenu et expliquer les lignes qui comportent : 

```
[vagrant@node1 ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

- ExecStart : permet d'indiquer la commande à exécuter au lancement du service.
- ExecStartPre : c'est la commande qui sera exécutée avant ExecStart
- PIDFile : PidFile est le nom du fichier dans lequel le serveur enregistre son identifiant de processus (PID).
- Type : Le type du service
- ExecReload : envoie un signal HUP (qui redémarre le service)
- Description : permet de donner une description du service qui apparaîtra lors de l'utilisation de la commande systemctl status <nom_du_service>
- After : permet d'indiquer quel pré-requis est nécessaire pour le fonctionnement du service.


Listez tous les services qui contiennent la ligne `WantedBy=multi-user.target` :

```
[vagrant@node1 ~]$ grep -r "WantedBy=multi-user.target" /usr/lib/systemd/system/
/usr/lib/systemd/system/ebtables.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nftables.service:WantedBy=multi-user.target
/usr/lib/systemd/system/remote-fs.target:WantedBy=multi-user.target
/usr/lib/systemd/system/sssd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/sshd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/remote-cryptsetup.target:WantedBy=multi-user.target
/usr/lib/systemd/system/systemd-resolved.service:WantedBy=multi-user.target
/usr/lib/systemd/system/tcsd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/crond.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rdisc.service:WantedBy=multi-user.target
/usr/lib/systemd/system/NetworkManager.service:WantedBy=multi-user.target
/usr/lib/systemd/system/irqbalance.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rpcbind.service:WantedBy=multi-user.target
/usr/lib/systemd/system/gssproxy.service:WantedBy=multi-user.target
/usr/lib/systemd/system/cpupower.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nginx.service:WantedBy=multi-user.target
/usr/lib/systemd/system/chrony-wait.service:WantedBy=multi-user.target
/usr/lib/systemd/system/dnf-makecache.timer:WantedBy=multi-user.target
/usr/lib/systemd/system/chronyd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs-client.target:WantedBy=multi-user.target
/usr/lib/systemd/system/nfs-server.service:WantedBy=multi-user.target
/usr/lib/systemd/system/auditd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/vmtoolsd.service:WantedBy=multi-user.target
/usr/lib/systemd/system/firewalld.service:WantedBy=multi-user.target
/usr/lib/systemd/system/tuned.service:WantedBy=multi-user.target
/usr/lib/systemd/system/rsyslog.service:WantedBy=multi-user.target
/usr/lib/systemd/system/kdump.service:WantedBy=multi-user.target
```


#### 3. Création d'un service


##### A. Serveur web


###### Créez une unité de service qui lance un serveur web

On créer un user `sudo useradd user2`.
On lui met un mot de passe `sudo passwd user2`.
On change la conf sudo avec `sudo visudo`.

On enlève le commentaire à la ligne : 
```
## Same thing without a password
# %wheel        ALL=(ALL)       NOPASSWD: ALL
```

Pour que ça ressemble à ça : 
```
## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

On fait la commande : `sudo usermod -aG wheel user2`

On configure notre unité de service : 
```
[vagrant@node1 ~]$ sudo vim /etc/systemd/system/web.service
```
(La config se trouve sur le git systemd/units/)


On fait nos scripts : 
```
[vagrant@node1 ~]$ sudo vim /usr/local/bin/start.sh
[vagrant@node1 ~]$ sudo vim /usr/local/bin/stop.sh
```
(Le contenu des scripts se trouve sur le git dans scripts_tp/)


###### Lancer le service

On lance le service avec la commande `sudo systemctl start web`.

Prouver qu'il est en cours de fonctionnement pour systemd : 
```
[vagrant@node1 ~]$ systemctl status web
● web.service - Service du tp3
   Loaded: loaded (/etc/systemd/system/web.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-10-07 18:24:40 UTC; 6s ago
  Process: 24613 ExecStartPre=/usr/bin/sudo /usr/local/bin/start.sh (code=exited, status=0/SUCCESS)
 Main PID: 24871 (sudo)
    Tasks: 0 (limit: 6107)
   Memory: 1.5M
   CGroup: /system.slice/web.service
           ‣ 24871 /usr/bin/sudo /usr/bin/python3 -m http.server 7777
```

Faites en sorte que le service s'allume au démarrage de la machine : 
```
[vagrant@node1 ~]$ sudo systemctl enable web
Created symlink from /etc/systemd/system/multi-user.target.wants/web.service to /etc/systemd/system/web.service.
```



Prouver que le serveur web est bien fonctionnel : 
```
[vagrant@node1 ~]$ curl 192.168.3.11:7777
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="swapfile">swapfile</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```

##### B. Sauvegarde

###### Créez une unité de service qui déclenche une sauvegarde avec votre script

On créer un user `sudo useradd backup`.
On lui met un mot de passe `sudo passwd backup`.

On fait la commande : `sudo usermod -aG wheel backup`

On configure notre unité de service : 
```
[vagrant@node1 ~]$ sudo vim /etc/systemd/system/backup.service
```
(La config se trouve sur le git dans systemd/units/)

On reload : 
`sudo systemctl daemon-reload`

On rempli l'index.html pour la forme.
```
[vagrant@node1 ~]$ sudo vim /srv/site1/index.html

[vagrant@node1 ~]$ cat /srv/site1/index.html
Index site1
```


```
[vagrant@node1 ~]$ sudo vim pre_backup.sh
[vagrant@node1 ~]$ sudo vim backup.sh
[vagrant@node1 ~]$ sudo vim after_backup.sh
```
(Le contenu des scripts se trouve sur le git dans scripts_tp/)


###### Ecrire un fichier .timer systemd

Lance la backup toutes les heures : 

On configure notre timer : 
```
[vagrant@node1 ~]$ sudo vim /usr/lib/systemd/system/backup.timer
```
(Sa config se trouve sur le git dans systemd/units/)

On démarre le timer et on lui dit de démarrer lorsque la machine démarre.
```
[vagrant@node1 ~]$ sudo systemctl start backup.timer
[vagrant@node1 ~]$ sudo systemctl enable backup.timer
```


On liste les timers pour vérifier qu'il est bien ajouté : 
```
[vagrant@node1 ~]$ systemctl list-timers
NEXT                         LEFT     LAST                         PASSED       UNIT                         ACTIVATE
Wed 2020-10-07 11:00:00 UTC  45s left n/a                          n/a          backup.timer                 backup.s
Thu 2020-10-08 08:45:14 UTC  21h left Wed 2020-10-07 08:45:14 UTC  2h 13min ago systemd-tmpfiles-clean.timer systemd-

2 timers listed.
```

Notre backup.timer est bien mis en place.

## II. Autres features

#### 1. Gestion de boot

On fait `systemd-analyze plot > plot.svg` pour récupérer les infos de la commande, puis on l'analyse.

Après analyse du fichier plot.svg, les 3 services les plus lents à démarrer sont : 
- web.service
- firewalld.service
- swapfile.swap


#### 2. Gestion de l'heure

```
[vagrant@node1 ~]$ timedatectl
      Local time: Wed 2020-10-07 13:27:26 UTC
  Universal time: Wed 2020-10-07 13:27:26 UTC
        RTC time: Wed 2020-10-07 13:27:26
       Time zone: UTC (UTC, +0000)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: n/a
```

###### Déterminer votre fuseau horaire : 

Ici mon fuseau horaire est UTC.


###### Déterminer si vous êtes synchronisés avec un serveur NTP : 

On est synchronisés avec un serveur NTP, on le voit avec la ligne : 
`NTP synchronized: yes`

###### Changer le fuseau horaire

Pour changer de fuseau horaire, je commence par les afficher avec la commande `timedatectl list-timezones | grep Europe`, puis on le change avec `sudo timedatectl set-timezone Europe/Madrid`.


```
[vagrant@node1 ~]$ sudo timedatectl
sudo timedatectl
      Local time: Wed 2020-10-07 15:35:57 CEST
  Universal time: Wed 2020-10-07 13:35:57 UTC
        RTC time: Wed 2020-10-07 13:35:57
       Time zone: Europe/Madrid (CEST, +0200)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  Sun 2020-03-29 01:59:59 CET
                  Sun 2020-03-29 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  Sun 2020-10-25 02:59:59 CEST
                  Sun 2020-10-25 02:00:00 CET
```

Mon fuseau horaire a bien été changé.

#### 3. Gestion des noms et de la résolution de noms

##### Utilisez hostnamectl

###### Déterminer votre hostname actuel

```
[vagrant@node1 ~]$ hostnamectl
   Static hostname: node1.tp3.b2
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 5750910a970e89419270392409bc854c
           Boot ID: 8a6aeeacb4b74ed9b97bd67c9368818e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
```

Mon hostname actuel est node1.tp3.b2.

###### Changer votre hostname

Pour changer le hostname, on fait la commande `[vagrant@node1 ~]$ sudo hostnamectl set-hostname new_node1`

On vérifie que le changement a été fait.

```
[vagrant@node1 ~]$ hostnamectl
   Static hostname: new_node1
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 5750910a970e89419270392409bc854c
           Boot ID: 8a6aeeacb4b74ed9b97bd67c9368818e
    Virtualization: kvm
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1127.19.1.el7.x86_64
      Architecture: x86-64
```

Mon hostname a bien été changé, c'est maintenant new_node1.