openstack-ironic-devenv
=======================

Setup OpenStack Ironic development environment


The script ironic-test.sh is a wrapper of tripleo devtest.sh, it is coded
according OpenStack Ironic wiki page:
https://wiki.openstack.org/wiki/Ironic


OS and Hardware
===============
Ubuntu 13.10 64B on ThinkPad T420

Steps
=====
1. NOPASSWD for sudo
   add a file to /etc/sudolers.d/
   e.g.  $ cat /etc/sudoers.d/01\_kui 
         kui ALL=(ALL) NOPASSWD:ALL

2. set the localhost as a squid3 server, which will cache all the http
   download, the second access of same URL will hit the squid3 cache, and get
   from it. 
   
   Modify the squid3.conf according the diff file:
   squid3-conf.diff

   check this file /var/log/squid3/access.log to confirm the server works well

3. patch 3 scripts in tripleo-incubator/scripts:
   devtest.sh
   devtest\_undercloud.sh
   pull-tools

   modify them according ironic-devenv.patch

4. run ironic-devenv.sh

