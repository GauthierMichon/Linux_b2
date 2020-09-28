#!/bin/bash

#On rentre dans la boucle si l'argument est /srv/site1
if [ $1 = /srv/site1 ]
then
        backup=site1_
        dest=/sauvegarde/site1

#On rentre dans la boucle si l'argument est /srv/site2	
elif [ $1 = /srv/site2 ]
then
        backup=site2_
        dest=/sauvegarde/site2
fi

#On compresse le fichier
tar -czf $backup$(date '+%Y%m%d_%H%M').tar.gz --absolute-names $1/index.html

#On move le fichier compressé
mv $backup$(date '+%Y%m%d_%H%M').tar.gz $dest

#On rentre dans la boucle s'il y a plus de 7 fichier dans le dossier
if [[ $(ls -Al $dest | wc -l) > 7 ]]
then
	#On supprime le fichier le plus ancien
        rm $dest/$(ls -tr1 $dest | grep -m 1 "")
fi


