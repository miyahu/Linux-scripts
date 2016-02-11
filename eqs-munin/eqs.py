#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
collection été utilisé pour trier le dict, mais ca ne sert à rien
piège:
dans Munin (c'est pas dans leur doc), ne pas mettre de _ dans le nom des valeurs
et aussi décomposer et utiliser de la manière suivante dans config :

 "nom du plugin"_"nom de la métrique"

"""

import requests
import sys
from collections import OrderedDict

my_server = 'pouet.ecritel.net'
my_uri = 'eqs/ecritel/infos'

ws_dict = OrderedDict()
as_dict = OrderedDict()

ws_dict = {\
    "graph_title":"File d'attente eqs",\
    "graph_args":"--base 1000 -l 0",\
    "graph_vlabel":"nb visiteurs",\
    "graph_category":"eqs",\
    "eqs_waiting-size.label":"waiting_size",\
    "eqs_waiting-size.type":"GAUGE",\
    }

as_dict = {\
    "eqs_allowed-size.label":"allowed_size",\
    "eqs_allowed-size.type":"GAUGE"\
    }
    

def plugin_config(ws_dict,as_dict):
    for i in OrderedDict(ws_dict):
        print("%s %s" % (i,ws_dict[i]))
    for i in OrderedDict(as_dict):
        print("%s %s" % (i,as_dict[i]))
    	
def execute():
    try:
        my_r = requests.get('http://%s/%s' % (my_server,my_uri))
    except :
        print("Unable to request this url %s/%s" % (my_server,my_uri))
    eqs_ws = my_r.json()['waiting_size']
    eqs_as = my_r.json()['allowed_size']
    print ("eqs_waiting-size.value %s \neqs_allowed-size.value %s" % (eqs_ws,eqs_as))

for arg in sys.argv:
    if 'config' in arg:
        plugin_config(ws_dict,as_dict)
        sys.exit()
    if '-h' in arg:
        print("Only 'config' is accepted in option")
        sys.exit()
    if len(sys.argv) < 2 :
        execute()
        sys.exit()
