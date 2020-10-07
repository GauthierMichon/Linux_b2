#!/bin/bash

# On crée une variable qui va récupérer la fin de l'argument
# Si l'argument est /toto/tata/titi, alors on récupère titi
backup_name="/srv/site1"

name=site1

# On crée une variable qui sera la destination de notre fichier de sauvegarde
destination="/sauvegarde/site1"

# On compresse le fichier
tar -czf ${name}$(date '+%Y%m%d_%H%M').tar.gz --absolute-names ${backup_name}/index.html

# On déplace le fichier qui vient d'être créé
mv ${name}$(date '+%Y%m%d_%H%M').tar.gz ${destination}