#!/bin/bash

/usr/sbin/ethtool -s eth1 speed 100 duplex full autoneg off
sleep  40
/usr/sbin/ethtool -s eth1 speed 100 duplex full autoneg on
sleep 100
if ! ping -c 5 "$1" ; then
        sync ;
        reboot ;
fi

