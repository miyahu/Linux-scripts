###


copy scripts into the "network up" destination
```bash
cp -v services-on-interface /etc/network/if-up.d/
```

You must declare the following vars  :

* IF_ALIAS_NAME = interface alias name ex eth0:www
* IF_ALIAS_ADDR = the alias ip address
* SERVICES services names (with space between)
 

create a hardlink to the "network down" destination
```bash
ln /etc/network/if-up.d/services-on-interface /etc/network/if-down.d/
```

