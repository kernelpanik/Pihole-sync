#!/bin/bash

#Variables
HAUSER=piholesyncuser 
SLAVE="pihole-slave"


# Stop Pihole & dump DB on master
systemctl stop pihole-FTL.service
sqlite3 /etc/pihole/pihole-FTL.db ".backup /home/$HAUSER/piholesync/pihole-FTL.db"

if [ $? -eq 0 ]; then
    echo "Dumping of pihole-FTL.db ... OK"
else
    echo "Dumping of pihole-FTL.db ... FAILED"
fi

sleep 1

# Dump gravity DB on master
sqlite3 /etc/pihole/gravity.db ".backup /home/$HAUSER/piholesync/gravity.db"

if [ $? -eq 0 ]; then
    echo "Dumping of gravity.db ... OK"
else
    echo "Dumping of gravity.db ... FAILED"
fi


# Start Pihole on master
systemctl start pihole-FTL.service

if [ $? -eq 0 ]; then
    echo "Pihole restarted correctly"
else
    echo "Pihole didn't restart"
fi

# Copy config files from master to SLAVE
chown -R pihole:pihole /home/$HAUSER/piholesync
scp /etc/dnsmasq.d/01-pihole.conf $HAUSER@$SLAVE:/home/$HAUSER/piholesync

if [ $? -eq 0 ]; then
    echo "Copying of 01-pihole.conf to $SLAVE ... OK"
else
    echo "Copying of 01-pihole.conf to $SLAVE ... ERROR"
fi


# Copy config files from master to SLAVE
scp /etc/dnsmasq.d/02-home-lab00.conf $HAUSER@$SLAVE:/home/$HAUSER/piholesync

if [ $? -eq 0 ]; then
    echo "Copying of 02-home-lab00.conf su $SLAVE ... OK"
else
    echo "Copying of 02-home-lab00.conf su $SLAVE ... ERROR"
fi


# Rsync piholesync folder from master to SLAVE
rsync -z -a /home/$HAUSER/piholesync $HAUSER@$SLAVE:/home/$HAUSER

if [ $? -eq 0 ]; then
    echo "rsync of piholesync folder to $SLAVE ... OK"
else
    echo "rsync of piholesync folder to $SLAVE ... ERROR"
fi


# Delete old domain list on SLAVE
ssh $HAUSER@$SLAVE "sudo -S rm -rf /etc/pihole/*.domains"


# Copy new domain list from master to SLAVE
rsync -a /etc/pihole/ --include  "*.domains" --exclude="*"  $HAUSER@$SLAVE:/home/$HAUSER/piholesync/domains

if [ $? -eq 0 ]; then
    echo "rsync domainlist to $SLAVE ... OK"
else
    echo "rsync domainlist to $SLAVE ... ERROR"
fi



# Stop Pihole on SLAVE
ssh $HAUSER@$SLAVE "sudo -S systemctl stop pihole-FTL.service"


# Mv file from piholesync folder to /etc/pihole
ssh $HAUSER@$SLAVE "sudo -S mv /home/piholesyncuser/piholesync/domains/*.domains /etc/pihole/"
ssh $HAUSER@$SLAVE "sudo -S mv /home/piholesyncuser/piholesync/*.db /etc/pihole/"
ssh $HAUSER@$SLAVE "sudo -S mv /home/piholesyncuser/piholesync/01-pihole.conf /etc/dnsmasq.d/01-pihole.conf"
ssh $HAUSER@$SLAVE "sudo -S mv /home/piholesyncuser/piholesync/02-home-lab00.conf /etc/dnsmasq.d/02-home-lab00.conf"


# Chown DB files
ssh $HAUSER@$SLAVE "sudo -S chown pihole:pihole /etc/pihole/*.db"
ssh $HAUSER@$SLAVE "sudo -S chown root:root /etc/pihole/*.domains"


# Restart pihole and update gravity on SLAVE
ssh $HAUSER@$SLAVE "sudo -S systemctl start pihole-FTL.service"
ssh $HAUSER@$SLAVE "sudo -S pihole -g "



# Clean up local files on master
rm -rf /home/$HAUSER/piholesync/*.db


