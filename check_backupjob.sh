#!/usr/bin/env bash

:<< EOF 
Check vérifiant que le job de backup s''est bien déroule. 
EOF

PATH="/usr/sbin:/usr/bin:/sbin:/bin"

### Nagios return code ###
_NAGIOS_STATUS_OK=0
_NAGIOS_STATUS_WARNING=1
_NAGIOS_STATUS_CRITICAL=2
_NAGIOS_STATUS_UNKNOWN=3

LOGFILE=/var/log/backupjob.log
STRING_OK="$1"

_tr=/usr/bin/tr

for prog in grep awk sed date ; do
	if type -ap $prog &> /dev/null ; then
		eval _$(echo $prog | $_tr [a-z] [A-Z])=$prog
	else
		echo "NOK : $prog introuvable, merci d'intervenir"
		exit $_NAGIOS_STATUS_UNKNOWN
	fi
done    

DATE_LIMIT=$((($($_DATE +%d)-2)))

compare_date() {
if ! (( $($_DATE -d $($_GREP -oE [[:digit:]]{2}/[[:digit:]]{2}/[[:digit:]]{2} $LOGFILE) +%d) >= $1 )) ; then
	echo "NOK : la sauvegarde remonte a plus de 2 jours, merci d'intervenir"
	exit $_NAGIOS_STATUS_CRITICAL
fi
}

search_string() {
if  [ -z $1 ] ; then
	echo "NOK : motif introuvable $1" 
	exit $_NAGIOS_STATUS_UNKNOWN
else
	if ! $_GREP -q $1 $LOGFILE ; then
		echo "NOK : la dernier sauvegarde ne s'est pas correctement déroulée"
		exit $_NAGIOS_STATUS_CRITICAL
	fi
fi
}

case $1 in

-h)
echo $($_SED -n 3p $0) ; exit $_NAGIOS_STATUS_OK
;;
esac

if compare_date $DATE_LIMIT && search_string $STRING_OK ; then
	echo "OK : backup complet et a jour" ;
	exit $_NAGIOS_STATUS_OK
fi

exit $_NAGIOS_STATUS_UNKNOWN


