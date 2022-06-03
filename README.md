# Pihole-sync
Bash script to sync between Pihole master &amp; slave


1) Create piholesyncuser on master and slave  

[root@pihole-master ~] adduser piholesyncuser  
[root@pihole-slave ~] adduser piholesyncuser  

2) add piholesyncuser to sudoers on slave 
vim /etc/sudoers./piholesync  
piholesyncuser    ALL=(ALL:ALL) ALL  

3) create piholesync on master & slave
[root@pihole-master ~] mkdir /home/piholesyncuser/piholesync      
[root@pihole-slave ~] mkdir /home/piholesyncuser/piholesync  

