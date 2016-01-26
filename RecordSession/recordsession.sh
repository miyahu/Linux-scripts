#!/bin/bash -

SESSION_PATH=/root/sessions/

if (( $UID == 0 )); then
	if [ ! -d $SESSION_PATH ] ; then
		echo "Create $SESSION_PATH" 
		if ! mkdir $SESSION_PATH ; then
			echo "Unable to create $SESSION_PATH" 
		fi
	fi
	script -a ${SESSION_PATH}script-$(date +%Hh%M-%d-%m-%y).out
fi
