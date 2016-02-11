#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import solr 
import sys
import os

my_servers = 'localhost:8983/solr'
my_core_name= 'ecritel'
my_status_uri = '/admin/cores?action=STATUS&core='
key_id = 2
key_name = 'ecritel_key'
key_value = 1000

my_host = ['8.8.8.8','google.fr']

class MyTest:

    def pingme(self, host):
        self.hostname = host

        status = os.system("ping -c 1 "+ self.hostname)

        if status == 0: 
            print("System " + self.hostname + " is UP !")
        else:
            print("System " + self.hostname + " is DOWN !")
        
    def curlme(self, host):
        self.hostname = host
        try:
            resp = requests.get('http://'+self.hostname+'/')
            if resp.status_code == 200:
                print 'ok'
            else:
                print 'nok'
        except: 
            print 'c la merde'



a = MyTest()

#print a.pingme('8.8.8.8')
#print a.pingme('google.fr')

for i in my_host :
    a.pingme(i)
    a.curlme(i)

