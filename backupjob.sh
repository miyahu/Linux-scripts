#!/bin/bash -

 Correspondance des répertoires/jours (date +%u)
# ------------------------------------------------
# Lundi :         1
# Mardi :         2
# Mercredi :      3
# Jeudi :         4
# Vendredi :      5
# Samedi :        6
# Dimanche :      7

# sauvegarde mensuel (date +%d)
# -----------------------------
# La sauvegarde quotidienne du 01 du mois en cours est copiée dans "month"


srcdir="/var/log/apache2 /root /etc /home /var/www/www.ruedelafete.com"
backupdir=/opt/nfs/backupdir/$(/bin/date +%u)
backup_month=/opt/nfs/backupdir/month
mylog=/var/log/$(basename ${0/\.sh/}).log
excludefile="sess_*"
requiredbin="/usr/bin/mail /bin/rm /bin/mkdir /bin/tar /usr/bin/mysqldump /bin/bzip2 /bin/cp" 
myname=$(basename ${0/.sh/}).pid



check_required() {
for i in $requiredbin ; do
	if [ ! -x  $i ] ; then
		echo "NOK : impossible de trouver $i" >> $mylog
	fi
done

for i in $srcdir $backupdir $backup_month $dbname ; do
	if [ -z $i ] ; then
		echo "NOK : $i est non defini" >> $mylog
	fi
done
}

controle_instance() {
	if [ -f /var/run/$myname ] ; then
		echo "Une instance est encore en cours"
		exit 0
	else
		touch /var/run/$myname
	fi
}

nettoyage() {
	rm -f /var/run/$myname
	exit 2
}


dir_funct() {
if [ -d $1 ] ; then
        if ! /bin/rm -rf $1 ; then
		echo "NOK : impossible de supprimer $1" >> $mylog
		nettoyage
	fi
fi

if ! /bin/mkdir -p $1 ; then
	echo "NOK : impossible de creer $1" >> $mylog
	nettoyage
fi
}

controle_instance

trap nettoyage INT TERM

echo "***** Job de sauvegarde du $(/bin/date +%D) *****" > $mylog
echo "start:$(date +%H:%M)" >> $mylog 

check_required 

dir_funct ${backupdir}

for i in $srcdir ; do
	#le changement de fichier durant la sauvegarde modifie le code retour de tar !!
	# donc pas de if ! /bin/tar zcf ... 
	/bin/tar zcf ${backupdir}/$(basename $i).tar.gz $i --exclude="$excludefile" 2>> $mylog 
	if ! /bin/tar ztf ${backupdir}/$(basename $i).tar.gz 2>> $mylog ; then
		echo "NOK : archive de $i corrompue" >> $mylog
		nettoyage
	fi

done

if (( $(/bin/date +%d) == 01 )) ; then
	dir_funct ${backup_month}
        if ! /bin/cp -a ${backupdir}/* ${backup_month}/ ; then
		echo "NOK : impossible de copier ${backupdir} vers ${backup_month}" >> $mylog
		nettoyage
	fi
fi

echo "stop:$(date +%H:%M)" >> $mylog 
echo "==OK==" >> $mylog

rm -f /var/run/$myname

