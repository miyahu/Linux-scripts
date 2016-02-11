#!/usr/bin/env bash 

## security tips ##
umask 077
\unalias -a
	
# dod = dump of the day 

my_hostname=""
my_homepath=/home/$(/usr/bin/whoami)
my_log=${my_homepath}/dod.log
my_hashname=${my_homepath}/hash_$(/bin/date +%F).txt
my_dumpname=${my_homepath}/dump_$(/bin/date +%F).sql
my_dbnames="arsshg arsshen pouet"
my_localdstdir=${my_homepath}/www/
my_localsrcdir=/var/www/glup
my_remotedstdir=/var/www/glup

if ! /usr/bin/whoami | /bin/grep transfert-agent ; then
	echo "le processus doit appartenir a transfert-agent"
	echo "sinon, merci de modifier $my_homepath et commenter ce if"
	exit 3
fi

if [ -f $my_log ] ; then
	>  $my_log
fi
 
prepare_dump() {
if ! /usr/bin/mysqldump -urouser -p$(/usr/bin/python -c "import base64 ; print base64.decodestring($(cat ${my_homepath}/.cred_mysql))") \
	 --databases $my_dbnames > $my_dumpname ; then
	echo "impossible de dumper les bases $my_dbnames" >> my_log
	exit 3
else
	if ! /usr/bin/tail -n 1 $my_dumpname | /bin/grep completed &> $my_log ; then
		echo "dump incomplet ou inexistant" >> $my_log ;
		exit 3 ;
	else 
		if ! /bin/gzip -f $my_dumpname &> $my_log ; then
			echo "impossible de zipper $my_dumpname" >> $my_log
			exit 3
		else
			if ! /usr/bin/md5sum ${my_dumpname}.gz > $my_hashname 2> $my_log ; then
				echo "impossible de faire un hash de $my_dumpname" >> $my_log ;
				exit 3
			fi
		fi
	fi
fi
}

load_dump() {
if ! /usr/bin/scp -C $my_hashname ${my_dumpname}.gz ${my_hostname}:~/ &> $my_log ; then
	echo "impossible de transferer les fichiers" >> $my_log ;
	exit 3
else
	rm -f $my_hashname ${my_dumpname}.gz
fi
}

load_remote_command() {
if ! /usr/bin/ssh $my_hostname "~/data_load.sh" 2> $my_log ; then
	echo "une erreur est survenue lors de l'execution de la commande distante" >> $my_log
	exit 3
fi
}

local_wwwsync() {
if ! sudo /usr/bin/rsync -aq $my_localsrcdir $my_localdstdir 2> $my_log ; then 
	echo "une erreur est survenue lors de la synchronisation de $my_localsrcdir vers $my_localdstdir" >> $my_log
fi
}

if ! sudo /usr/bin/rsync -azv -e ssh $my_localdstdir ${my_hostname}:${my_remotedstdir} ; then 
	echo "une erreur est survenue lors de la synchronisation de ${my_hostname}:/$my_remotedstdir" >> $my_log
fi
}

case "$1" in 
dump)
	prepare_dump	
	~/$0 load
;;
load) 
	load_dump
	$0 rexecute
;;
rexecute)
	load_remote_command
;;
copy)
	local_wwwsync
;;
rcopy) 
	remote_wwwsync
;;
esac
