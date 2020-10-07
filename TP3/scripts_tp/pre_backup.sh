#!/bin/bash

# On crée une variable qui va récupérer la fin de l'argument
# Si l'argument est /toto/tata/titi, alors on récupère titi
backup_name='/srv/site1'

# On crée une variable qui sera la destination de notre fichier de sauvegarde
destination='/sauvegarde/site1'

if [ ! -d ${backup_name} ]
then
    echo "le dossier demande n'existe  pas ${backup_name}"
        exit 1
fi

# On rentre dans la boucle si le dossier est vide
if [ ! -e ${backup_name}/index.html ]
then
    echo "le dossier demandé ne contient pas d'index.html"
    exit 1
fi

if [ ! -d ${destination} ]
then
    mkdir ${destination}
fi