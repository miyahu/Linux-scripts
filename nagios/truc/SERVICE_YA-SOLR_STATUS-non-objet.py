#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import solr 
import sys

my_servers = 'localhost:8983/solr'
my_core_name= 'ecritel'
my_status_uri = '/admin/cores?action=STATUS&core='
key_id = 2
key_name = 'ecritel_key'
key_value = 1000

my_errors = {}

def get_status(my_servers,my_status_uri,my_core_name):
    my_solr_curs = requests.get('http://%s%s%s&wt=json' % (my_servers,my_status_uri,my_core_name))
    my_solr_uptime = my_solr_curs.json()['status']['ecritel']['uptime']
    if my_solr_uptime > 0:
        print('ok, uptime %s' % my_solr_uptime)
    else:
        print('error','status','')
    


def search_ecritel_key(my_servers,my_core_name,key_id):
    print("searching key")
    my_solr_curs = solr.SolrConnection('http://%s/%s' % (my_servers,my_core_name))
    try: 
        my_solr_id = my_solr_curs.query('id:%s' % key_id)
    except:
        print("Unable to obtain keys id:%s from %s/%s" % (key_id,my_servers,my_core_name)) 
        sys.exit()
    if len(my_solr_id) > 0:
        for hit in my_solr_id.results:
            my_val = hit['valeur']
            my_val = ''.join(my_val) # on convertie la liste en string
            my_val = int(my_val)
            print my_val
            if my_val > 0:
                print("ok %s" % my_val)
            else:
                print"beu"
    else:
        print("There no key with id %s" % key_id)

def write_ecritel_key(my_servers,my_core_name,key_id,key_name,key_value):
    print("writing key")
    my_solr_curs = solr.SolrConnection('http://%s/%s' % (my_servers,my_core_name))
    my_solr_curs.add(id=key_id, name=key_name, valeur=key_value)
    my_solr_curs.commit()

def delete_ecritel_key(my_servers,my_core_name,key_id):
    print("deleting key")
    my_solr_curs = solr.SolrConnection('http://%s/%s' % (my_servers,my_core_name))
    my_solr_curs.delete(id=key_id)
    my_solr_curs.commit()

get_status(my_servers,my_status_uri,my_core_name)


write_ecritel_key(my_servers,my_core_name,key_id,key_name,key_value)

search_ecritel_key(my_servers,my_core_name,key_id)

delete_ecritel_key(my_servers,my_core_name,key_id)

