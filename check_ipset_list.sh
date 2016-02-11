#!/usr/bin/env bash

if /usr/sbin/ipset --list af_dyn &> /dev/null ; then 
	echo "ok la liste af_dyn existe"
	exit 0
else
	echo "nok la liste af_dyn n existe pas"
	exit 2
fi
	

