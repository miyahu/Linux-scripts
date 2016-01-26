#!/bin/bash -

SESSION_PATH=/root/sessions/

if (( $UID == 0 )); then
	if [ ! -d $SESSION_PATH ] ; then
		 mkdir $SESSION_PATH
	else
		echo "Unable to create $SESSION_PATH" 
	fi
	script -a ${SESSION_PATH}script-$(date +%Hh%M-%d-%m-%y).out
fi
