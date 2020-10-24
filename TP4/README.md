# README

Mon user et mon mot de passe pour la bdd sont gitea et gitea.

Avant de vagrant up, il faut faire une package une box avec vim, selinux de désativer, et le firewall d'activer. On appellera cette box, `b2-tp4-centos`.

On install vim : `sudo yum -y install vim`.

Pour désactiver selinux, on fait un `sudo setenforce 0`. Ensuite, on change le fichier /etc/selinux/config pour qu'il ressemble à ça :

[vagrant@node1 ~]$ cat /etc/selinux/cosnfig

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

Et on, on active le firewall a chaque démarrage : `sudo systemctl enable firewalld`.

## Liste des hosts

| name | IP   | Role |
| ---- | ---- | ---- |
| gitea|192.168.4.11|Serveur hebergeant le Gitea|
| mariadb|192.168.4.12|Serveur hebergeant la bdd|
| nginx|192.168.4.13|Serveur Nginx qui renvoie sur le gitea|
| nfs|192.168.4.14|Serveur qui sert de sauvegarde aux autres|