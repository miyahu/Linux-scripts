#!/bin/bash -

_ipset=/usr/sbin/ipset

case $1 in 

search)
	if $_ipset -T $2 $3 &> /dev/null ; then
		echo "L"\'"IP est dans le set $2"
	else
		echo "L"\'"IP n"\'"est pas dans le set $2"
	fi
;;
add)  
	if $_ipset -A $2 $3 &> /dev/null ; then
		echo "IP ajoutee au set $2"
	else
		echo "Impossible d"\'"ajouter l"\'"IP au set $2"
		$0 search $2 $3
	fi
;;
del)  
	if $_ipset -D $2 $3 &> /dev/null ; then
		echo "IP supprimee du set $2"
	else
		echo "Impossible de supprimer l"\'"IP du set $2"
		$0 search $2 $3
	fi
;;
status)
	if [ ! -z $2 ] ; then
		 $_ipset -L $2
	else
		 $_ipset -L 
	fi
;;		
*)
echo "Usage : $0 search OU add OU del ET "\"set name"\" ET "\"adresse IP"\""
echo "Usage : $0 status "\"set name"\" pour obtenir les IP du set"
echo "Usage : $0 status pour obtenir les IP de tous les set"
echo "Ou "\"set name"\" est le nom du set abritant les adresses IP statiques ou dynamiques autorisees :"
echo " - set statique : af_stat"
echo " - set dynamique : af_dyn"
echo "Exemples d"\'"utilisation :"
echo " - Je veux savoir si l"\'"IP 8.8.8.8 est dans le set af_stat : $0 search af_stat 8.8.8.8"
echo " - Je veux supprimer l"\'"IP 8.8.8.8 presente dans le set af_stat : $0 del af_stat 8.8.8.8"
echo " - Je veux ajouter l"\'"IP 8.8.8.8 au set af_dyn : $0 add af_dyn 8.8.8.8"
echo " - Je veux lister les IP presentes dans tous les set :  $0 status"
echo " - Je veux lister les IP presentes dans le set af_dyn :  $0 status af_dyn"
;;
esac

