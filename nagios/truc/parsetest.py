#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse

"""
type : standalone || cluster
role
master_server 
slave_server 
my_servers 
my_core_name 
my_status_uri = '/admin/cores?action=STATUS&core=


les options passé : role et truc sont des méthodes
"""

parser = argparse.ArgumentParser()
parser.add_argument('type', help='type of server: standalone or replica')
parser.add_argument('role', nargs='?',help='role of server: master or slave')
parser.add_argument('--truc', nargs='?',choices=['rock', 'paper', 'scissors'],help='truc: master or slave')

#parsr.add_argument('truc', help='truc help')


args = parser.parse_args()

if 'type' in args :
    if 'standalone' in  args.type:
        print 'pouet'
        print args.type
        print type(args.type)
    if 'cluster' in args.type:
        if 'role' in args:
            if 'master' in  args.type:
                print "j'aime les master !!"
            if 'slave' in  args.type:
                print "j'aime les slave !!"
        else:
            print 'you must provide a role'
        
#for i in args:
#    print i

