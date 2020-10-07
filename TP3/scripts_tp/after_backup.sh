#!/bin/bash

# On crée une variable qui va récupérer la fin de l'argument
# Si l'argument est /toto/tata/titi, alors on récupère titi
backup_name="/srv/site1"

# On crée une variable qui sera la destination de notre fichier de sauvegarde
destination="/sauvegarde/site1"

# On rentre dans la boucle s'il y a plus de 7 fichier dans le dossier
if [[ $(ls -Al ${destination} | wc -l) > 7 ]]
then
    rm ${destination}/$(ls -tr1 ${destination} | grep -m 1 "")
fi