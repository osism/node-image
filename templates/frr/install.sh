#!/bin/bash

set -x

BASE="/root/frr"
SYSTEM_HOSTNAME="$(ipmitool dcmi get_mc_id_string|awk '/^.*:/{hostname=$0;gsub(/^(..*): /, "", hostname);printf("%s", hostname); exit}')"
BMC_IP="$(ipmitool lan print |awk '/^IP Address[ ]*:/{hostname=$0;gsub(/^(..*): /, "", hostname);printf("%s", hostname); exit}')"
IP_SUFFIX="$(echo "$BMC_IP"|grep -P -oh '\d+$')"

echo "Name is: $SYSTEM_HOSTNAME, IP suffix is: $IP_SUFFIX, BMC IP is: $BMC_IP"

dpkg -i  $BASE/*.deb
# otherwise, apt-get autoremove revoves the packages at the end of the installation
ls -1 $BASE/*.deb|sed -e 's,_.*$,' -e 's,^.*/,,' | xargs apt-mark manual

echo $SYSTEM_HOSTNAME > /etc/hostname


rm -f /etc/netplan/00-installer-config.yaml
sed -e "s/OSISM_IP/$IP_SUFFIX/" $BASE/01-osism.yaml > /etc/netplan/01-osism.yaml
chmod 600 /etc/netplan/01-osism.yaml
sed -e "s/OSISM_IP/$IP_SUFFIX/" -e "s/OSISM_HOST/$SYSTEM_HOSTNAME/" $BASE/frr.conf > /etc/frr/frr.conf
cp $BASE/daemons /etc/frr/
cp $BASE/05-dummy0.netdev /etc/systemd/network/
chmod 600 /etc/systemd/network/05-dummy0.netdev
chown systemd-network:root /etc/systemd/network/05-dummy0.netdev

systemctl restart systemd-networkd

netplan apply
systemctl restart frr

DUMMY_IPV="$(ip -o -4 addr list dummy0 | awk '{print $4}' | cut -d/ -f1)"
echo "\n - \S - IP - ${DUMMY_IPV4}" > /etc/issue

vtysh -c "show ip bgp summary"
