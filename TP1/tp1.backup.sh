#!/bin/bash

# On crée une variable qui va récupérer la fin de l'argument
# Si l'argument est /toto/tata/titi, alors on récupère titi
backup_name="$(basename $1)"

# On crée une variable qui sera la destination de notre fichier de sauvegarde
destination="/sauvegarde/${backup_name}"

if [ ! -d ${1} ]
then
        echo "le dossier demandé n'existe pas $1"
        exit 1
fi

# On rentre dans la boucle si le dossier est vide
if [ ! -e ${1}/index.html ]
then
        echo "le dossier demandé ne contient pas d'index.html"
        exit 1
fi

if [ ! -d ${destination} ]
then
        mkdir ${destination}
fi

# On compresse le fichier
tar -czf ${backup_name}$(date '+%Y%m%d_%H%M').tar.gz --absolute-names ${1}/index.html

# On déplace le fichier qui vient d'être créé
mv ${backup_name}$(date '+%Y%m%d_%H%M').tar.gz ${destination}

# On rentre dans la boucle s'il y a plus de 7 fichier dans le dossier
if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
        rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi

