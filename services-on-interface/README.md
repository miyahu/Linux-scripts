### services-on-interface

Features :
* activate service when interface becomes up
* deactivate service when interface becomes down
* stop when address ip is already active on network 

1. add this following lines into the /etc/network/interfaces file's
```bash
auto eth0:www
iface eth0:www inet manual
```

2. copy scripts into the "network up" destination
```bash
cp -v services-on-interface /etc/network/if-up.d/
```

3. create a hardlink to the "network down" destination
```bash
ln /etc/network/if-up.d/services-on-interface /etc/network/if-down.d/
```

4. Declare the following vars :
* IF_ALIAS_NAME : interface alias name ex eth0:www (ip addr label or $IFACE)
* IF_ALIAS_ADDR : the ip address alias
* SERVICES : services names (with space between)

