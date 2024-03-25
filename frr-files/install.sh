#!/bin/bash

set -x

BASE=/frr-files
NAME=$(ipmitool user list | awk '/OSISM/ {print substr($2,6)}')
IP=${NAME:5}

echo Name is: $NAME, IP suffix is: $IP

echo $NAME > /etc/hostname
echo "\n - \S - IP - 10.10.21.$IP" > /etc/issue

rm -f /etc/netplan/00-installer-config.yaml
sed -e "s/IP/$IP/" $BASE/01-osism.yaml > /etc/netplan/01-osism.yaml
sed -e "s/IP/$IP/" -e "s/HOST/$NAME/" $BASE/frr.conf > /etc/frr/frr.conf
cp $BASE/daemons /etc/frr/
cp $BASE/05-dummy0.netdev /etc/systemd/network/

netplan apply
systemctl restart frr
