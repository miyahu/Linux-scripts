#!/usr/bin/env bash

:<< EOF
Usage :
Serveur principal aa
Serveur secondaire bb

exemple ~# switch_server.sh primary all
Associe dans le fichier /etc/hosts l'ip d'ETAI93 au nom de domaine sqlcluster.sim.lan

Option primary : insert primary server in  the hosts file 
Option secondary : insert secondary server in  the hosts file 
Option restart : restart Tomcat on the local and remote server

Option local : apply action on the local server
Option remote : apply action on the remote server
EOF

#Security tips 
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SCRIPT_PATH=/ECRITEL/EXPLOITATION/TOOLS/tomcat/switch-server.sh

SQL_CLUSTER_NAME=sqlcluster.pouet.lan

SERVICE_NAME=tomcat6


FILE_PATH=/etc/hosts
BACKUP_DIR=/var/backups/conf/etc/
FILE_NAME=$(basename $FILE_PATH)

test_hostname_function() {
	if hostname | grep -q 103 ; then
		return 103
	elif hostname | grep -q 104 ; then
		return 104
	fi	
}

local_restart_tomcat_function() {
	if ! service tomcat6 restart ; then
		echo "NOK : Imposible de recharger $SERVICE_NAME, merci d'intervenir" ;
		exit 2
	fi
}

remote_restart_tomcat_function() {
	if (( $MY_HOSTNAME == 103 )); then
		if ! ssh -i /home/ecritel/.ssh/id_rsa ecritel@104 "sudo /usr/sbin/service tomcat6 restart" ; then
			echo "NOK : Imposible de stopper $SERVICE_NAME sur , merci d'intervenir" ;
			exit 2
		fi
	elif (( $MY_HOSTNAME == 104 )) ; then
		if ! ssh -i /home/ecritel/.ssh/id_rsa ecritel@103 "sudo /usr/sbin/service tomcat6 restart" ; then
			echo "NOK : Imposible de stopper $SERVICE_NAME sur , merci d'intervenir" ;
			exit 2
		fi
	fi
}

remote_change_hosts_function() {
	if (( $MY_HOSTNAME == 103 )); then
		if ! ssh -i /home/ecritel/.ssh/id_rsa ecritel@104 "sudo $SCRIPT_PATH $1 local" ; then
			echo "NOK : Imposible de changer $SCRIPT_PATH sur 104, merci d'intervenir" ;
		fi
	elif (( $MY_HOSTNAME == 104 )) ; then
		if ! ssh -i /home/ecritel/.ssh/id_rsa ecritel@103 "sudo $SCRIPT_PATH $1 local" ; then
			echo "NOK : Imposible de changer $SCRIPT_PATH sur 103, merci d'intervenir" ;
		fi
	fi
}

backup_file_function() {
	if [ ! -d ${BACKUP_DIR} ] ; then
		if ! mkdir -p ${BACKUP_DIR} ; then
			echo "NOK : Imposible de creer ${BACKUP_DIR}, merci d'intervenir" ;
			exit 2
		else
			if ! cp $FILE_PATH ${BACKUP_DIR}${FILE_NAME}-$(date +%d-%m-%y-%H-%M) ; then
				echo "NOK : Impossible de copier le fichier $FILE_NAME dans $BACKUP_DIR, merci d'intervenir" ;
				exit 2
			fi
		fi
	fi
}

change_hosts_function() {
	PRIMARY_HOSTS_VALUE="172.16.20.49 sqlcluster.sim.lan"
	SECONDARY_HOSTS_VALUE="172.16.20.50 sqlcluster.sim.lan"

	backup_file_function

	if [ $1 == "primary" ] ; then 
		if ! sed -ie "s/\([[:digit:]]\|\.\)\+\ sqlcluster\.sim\.lan/$PRIMARY_HOSTS_VALUE/" $FILE_PATH ; then
				echo "NOK : Imposible de modifier le fichier $FILE_PATH, merci d'intervenir" ;
				exit 2
			else
				echo "OK: changement du fichier $FILE_PATH réussie" ;
		fi
	elif [ $1 == "secondary" ] ; then
		if ! sed -ie "s/\([[:digit:]]\|\.\)\+\ sqlcluster\.sim\.lan/$SECONDARY_HOSTS_VALUE/" $FILE_PATH ; then
				echo "NOK : Imposible de modifier le fichier $FILE_PATH, merci d'intervenir" ;
				exit 2
			else
				echo "OK: changement du fichier $FILE_PATH réussie" ;
		fi
	fi

	#$SCRIPT_PATH restart
}

list_hosts_entry_function() {
	if (( $MY_HOSTNAME == 103 )); then
		echo "ETAI104"
		if ! ssh -i /home/ecritel/.ssh/id_rsa 104 "grep sqlcluster.sim.lan /etc/hosts" ; then
				echo "NOK : Imposible d'afficher le fichier $FILE_PATH, merci d'intervenir" ;
				exit 3		
		fi
	elif (( $MY_HOSTNAME == 104 )) ; then
		echo "ETAI103"
		if ! ssh -i /home/ecritel/.ssh/id_rsa 103 "grep sqlcluster.sim.lan /etc/hosts" ; then
				echo "NOK : Impossible d'afficher le fichier $FILE_PATH, merci d'intervenir" ;
				exit 3		
		fi
	fi
}

	## on fixe le hostname ##
	test_hostname_function
	export MY_HOSTNAME=$?

case "$1" in
	primary)
		case $2 in 
			local)
				change_hosts_function $1
			;;
			remote)
				remote_change_hosts_function $1	
			;;
			all)
				$SCRIPT_PATH primary local
				$SCRIPT_PATH primary remote
				$SCRIPT_PATH restart all
			;;	
		esac
	;;	

	secondary)
		case $2 in 
			local)
				change_hosts_function $1
			;;
			remote)
				remote_change_hosts_function $1
			;;
			all)
				$SCRIPT_PATH secondary local
				$SCRIPT_PATH secondary remote
				$SCRIPT_PATH restart all
			;;	
		esac	
	;;
	restart)
		case $2 in
			local)
				local_restart_tomcat_function
			;;
			remote)
				remote_restart_tomcat_function $1
			;;
			all)
				$SCRIPT_PATH restart local
				$SCRIPT_PATH restart remote
			;;
		esac
	;;
	list)
		list_hosts_entry_function
		echo $(hostname | tr [a-z] [A-Z])
		grep sqlcluster.sim.lan /etc/hosts 
	;;
	test)
		test_hostname_function
	;;
	help)
		sed -n '4,7p' $0
	;;
esac
