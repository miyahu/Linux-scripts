#!/bin/bash -

my_log=~/dod.log
my_hashfile=hash_$(/bin/date +%F).txt
my_dumpfile=dump_$(/bin/date +%F).sql

> $my_log

if ! [ -f ~/$my_hashfile ] ; then
	echo "le fichier hash n'existe pas" >> $my_log
	exit 3
else
	if ! /usr/bin/md5sum -c $my_hashfile &> $my_log ; then
		echo "hash incorrect ou fichier dump inexistant" >> $my_log
		exit 3
	else
		if ! [ -f ~/${my_dumpfile}.gz ] ; then
			echo "le fichier dump n'existe pas" >> $my_log
			exit 3
		else 	
			if ! /bin/gunzip -fd ${my_dumpfile}.gz &> $my_log ; then
				echo "impossible de decompresser le fichier" >> $my_log 
				exit 3
			else
				if ! /usr/bin/mysql -uroot -p$(/bin/cat db_pass.txt) < $my_dumpfile &> $my_log ; then	
					echo "impossible d'injecter le dump" >> $my_log 
					exit 3
				else
					/bin/rm -f $my_hashfile $my_dumpfile $my_log
				fi
			fi
		fi
	fi
fi

