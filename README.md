# Pihole-sync
Bash script to sync between Pihole master &amp; slave


1) Create piholesyncuser on master and slave  
[root@pihole-master ~] adduser piholesyncuser  
[root@pihole-slave ~] adduser piholesyncuser  

2) Add piholesyncuser to sudoers on slave   
vim /etc/sudoers./piholesync  
and add this line:  
piholesyncuser    ALL=(ALL:ALL) ALL  

3) Create piholesync folder on master & slave  
[root@pihole-master ~] mkdir /home/piholesyncuser/piholesync      
[root@pihole-slave ~] mkdir /home/piholesyncuser/piholesync  

4) Copy ssh key from master to slave for passwordless login  
ssh-copy-id -i ~/.ssh/mykey piholesyncuser@pihole-slave    

5) Run as root  
