:<<EOF
regles de programmation
	- on ne redirige pas la sortie d'erreur
	- une erreur doit sortir avec un code > 0
	- ne pas forcer un code retour "optimiste" ex 0, laissez la fonction se  terminer naturellement
	- la syntaxe doit etre clair
	- ne pas fixer le chemin des binaires, c'est idiot : définir un PATH sécurisé à la place 

EOF
######################################################
##   FONCTIONS STANDARD   ############################
######################################################

lib_cleaning_function() {
:<<EOF
Nettoyage
EOF
	ARG1=$SCRIPTNAME
	for element in $@ ; do
		if [ -e $element ] ; then
			if ! $_RM -f $element ; then
				echo "Unable to delete $element"
				return 3
			fi
		else
			echo "$element not found"
			return 3
		fi
	done
	RUN_PATH="var/run /tmp" 
	for path_dir in $RUN_PATH ; do
		if [ -f ${path_dir}/$SCRIPTNAME ] ; then
			if ! $_RM -f ${path_dir}/$SCRIPTNAME ; then
				echo "Unable to delete ${path_dir}/$SCRIPTNAME" ;
				return 3
			fi
		fi
	done
}


lib_create_dir_function() {
:<<EOF
Creation de repertoire
EOF
	for element in $@ ; do
		if [ -d $element ] ; then
			echo "$element already exist" 
			return 3
		else
			if ! $_MKDIR -p $element ; then
        			echo "Unable to create $element" 
				return 3
			fi
		fi
	done
}

lib_delete_dir_function() {
:<<EOF
Suppression de repertoire
EOF
	for element in $@ ; do
		if [ ! -d $element ] ; then
			echo "$element not found"
			return 3
		else
			if ! $_RMDIR $element ; then
        			echo "Unable to delete $element" 
				return 3
			fi
		fi
	done
}

lib_catch_ctrlc_function() {
:<<EOF
Intercepte le Ctrl+C et nettoie
EOF
	trap cleaning_funct INT TERM
}

lib_check_bin_function() {
:<<EOF
Verifie la presence des binaires requis
Par securite :
 - on fixe le PATH ;
 - on ne tiens pas compte des alias.
EOF

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
\unalias -a

	_tr=tr

	for element in $@ ; do
		 if type -ap $element &> /dev/null ; then
			eval _$(echo $element | $_tr [a-z] [A-Z])=$element	
		else 
			echo "$i not found"
			return 3
		fi
done
}

lib_init_process_context_function() {
ARG1=$1
	if (($($_ID -u) == 0)) ; then
		if [ ! -d /var/run ] ; then
			echo "directory /var/run not found"
			return 3
		else
			if ! echo "$$" > /var/run/$ARG1 ; then
				echo "Unable to create /var/run/$ARG1 pid file"
				return 3
			fi
		fi
	else
		if ! echo "$$" > /tmp/$ARG1 ; then
			echo "Unable to create /tmp/$ARG1 pid file"
			return 3
		fi
	fi
}

lib_check_onlyone_instance_file_function() {
:<<EOF
$1 = nom du programme
EOF
ARG1=$1
	if (($($_ID -u) == 0)) ; then
		if [ ! -d /var/run ] ; then
			echo "directory /var/run not found"
			return 3
		else
			if [ -f /var/run/$ARG1 ] ; then
				echo "Pid file found in /var/run/, maybe the programm still running !!!"
				return 3
			fi
		fi
	else
		if [ -f /tmp/$ARG1 ] ; then
			echo "Pid file found in /tmp/, maybe the programm still running !!!"
			return 3
		fi
	fi
}

lib_check_onlyone_instance_processlist_function() {
:<<EOF
Description :
Verification qu'aucune instance du programme donné en argument est presente
$1 = nom du programme
EOF
	if $_PGREP -xo $1 1> /dev/null ; then
		echo "Pid file found, maybe the programm still runing !!!"
		return 3
	fi
}

lib_control_user_function() {
	local ARG1="$1"
	local dep="id grep"
	local help="help function"
	if [ $ARG1 == "dep" ] ; then
		echo $dep 
	elif [ $ARG1 == "help" ] ; then
		echo "help"
	fi

	if ! $_ID -un | $_GREP -q "$ARG1" ; then
		echo "You must be $ARG1" ;
		return 2
	fi
}

lib_if_fct_exist_function() {
	local ARG1="$1"
	local dep=""
	local help="help function"
	if [ $ARG1 == "dep" ] ; then
		echo $dep 
	elif [ $ARG1 == "help" ] ; then
		echo "help"
	fi
	if ! builtin type -p $ARG1 ; then
		echo "Function doesn't exist" ;
		return 2
	fi
}

######################################################
##   FONCTIONS DATES et MARQUEUR    ##################
######################################################


compare_date_with_slash_separator_funct() {
:<<EOF
Description :
Verification qu'aucune instance du programme donné en argument est presente
$1 = nom du programme
$2 = code retour
EOF
DATE_TO_COMPARE=$1
FILE_TO_COMPARE=$2

	if [ -z $1 ] ; then
		echo "Motif not found" ;
		return 3
	elif [ -z $2 ] ; then 
		echo "File not define" ;
		return 3
	elif [ -e $2 ] ; then 
		echo "File not found" ;
		return 3
	else
		if ! (( $($_DATE -d $($_GREP -oE [[:digit:]]{2}/[[:digit:]]{2}/[[:digit:]]{2} $2) +%d) >= $1 )) ; then
        		echo "NOK : la sauvegarde remonte a plus de 2 jours, merci d'intervenir"
        		return
		fi                                                                                                                                                                                                                                             
	fi
}   

######################################################
##   FONCTIONS RECHERCHE DE MOTIFS   #################
######################################################

print_single_ipaddress() {
# Description :
# Affiche l'adresse de l'interface donnée en argument.
# ---
# Arguments :
# $1 est le nom de l'interface
# ---
# Exemple d'utilisation :
# if [ $(print_single_ipaddress eth0) != 10.100.0.10 ] ; then
#	...

	check_bin_funct grep ip head

	if [ -z $1 ] ; then
		echo "Interface name not found" ;
		return 3
	else
		INTERFACE_NAME=$1 ;
		INTERFACE_ADDRESS=$($_IP addr show dev $INTERFACE_NAME 2> /dev/null | $_GREP -Eo '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' | $_HEAD -n 1) 
		if [ ! -z $INTERFACE_ADDRESS ] ; then
			echo $INTERFACE_ADDRESS ;
		else
			echo "Unable to get the address"
			return 3
		fi
	fi
}

######################################################
##        FONCTIONS LOGGING          #################
######################################################

starting_function() {	
	echo -e "\t*.*.*.* $(basename $0) job $(/bin/date +%D) *.*.*.*"
	echo "start:$(date +%H:%M)" 
	echo "PID:$$" 
}
stopping_function() {	
# motif : ==OK== 
	echo "stop:$(date +%H:%M)" 
	echo "==OK==" 
	echo -e "\t*.*.*.* End job *.*.*.*"
}



