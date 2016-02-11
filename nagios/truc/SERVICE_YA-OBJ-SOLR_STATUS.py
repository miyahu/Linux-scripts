#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Dépendances : pip install requests solr
"""

import requests
import solr 
import sys
import time

master_server = 'localhost'
slave_server = 'mdp11'
my_servers = [master_server, slave_server]
my_core_name= 'ecritel'
my_status_uri = '/admin/cores?action=STATUS&core='

class SolrReplicationCheck:
    """
    cette classe a trois méthodes :
        - get_status
        - search_key
        - write_key
         -delete_key
    """

    def get_status(self, server, uri, core):

        self.server_name = server+':8983/solr'
        self.uri_name = uri
        self.core_name = core

        my_solr_curs = requests.get('http://'+self.server_name+self.uri_name+self.core_name+'&wt=json')
        my_solr_uptime = my_solr_curs.json()['status']['ecritel']['uptime']
        if my_solr_uptime > 0:
            print('ok, uptime: %i' % my_solr_uptime)
        else:
            print('error','status','')

    def search_key(self, server, core, key):

        self.server_name = server+':8983/solr'
        self.core_name = core
        self.key_name = key

        print("searching key")
        my_solr_curs = solr.SolrConnection('http://'+self.server_name+'/'+self.core_name)
        try: 
            my_solr_id = my_solr_curs.query('id:%i' %self.key_name)
        except:
            print ('Unable to obtain keys id: %i from %s/%s' % (self.key_name,self.server_name,self.core_name)) 
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
            print('There no key with id %i' % self.key_name)

    def write_key(self, server, core, key_id, key_name, key_value):

        self.server_name = server+':8983/solr'
        self.core_name = core
        self.key_id = key_id
        self.key_name = key_name
        self.key_value = key_value

        my_solr_curs = solr.SolrConnection('http://'+self.server_name+'/'+self.core_name)
        my_solr_curs.add(id=self.key_id, name=self.key_name, valeur=self.key_value)
        my_solr_curs.commit()
        print('writing key id:%i name:%s value: %s' % (self.key_id,self.key_name,self.key_value))
        
    def delete_key(self, server, core, key):

        self.server_name = server+':8983/solr'
        self.core_name = core
        self.key_name = key

        print("deleting key")
        my_solr_curs = solr.SolrConnection('http://'+self.server_name+'/'+self.core_name)
        my_solr_curs.delete(id=self.key_name)
        my_solr_curs.commit()

##########
# Engine #
##########

# on instancie myobj
myobj = SolrReplicationCheck()

# et on accède aux méthodes
for H in my_servers:

    myobj.get_status(H, my_status_uri, my_core_name)

    if 'localhost' in H:
        myobj.write_key(H, my_core_name, 2, 'ecritel_key', '1400')

    time.sleep(3) # tenir compte du délai de replication

    myobj.search_key(H, my_core_name, 2)

# enfin on supprime la clé après la boucle
myobj.delete_key(master_server, my_core_name, 2)
