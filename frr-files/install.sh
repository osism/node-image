#!/bin/bash

set -x

BASE=/frr-files
SYSTEM_HOSTNAME="$(ipmitool dcmi get_mc_id_string|awk '/^.*:/{hostname=$0;gsub(/^(..*): /, "", hostname);printf("%s", hostname); exit}')"
BMC_IP="$(ipmitool lan print |awk '/^IP Address[ ]*:/{hostname=$0;gsub(/^(..*): /, "", hostname);printf("%s", hostname); exit}')"
IP_SUFFIX="$(echo "$BMC_IP"|grep -P -oh '\d+$')"

echo "Name is: $SYSTEM_HOSTNAME, IP suffix is: $IP_SUFFIX, BMC IP is: $BMC_IP"

echo $SYSTEM_HOSTNAME > /etc/hostname
echo "\n - \S - IP - 10.10.21.$IP_SUFFIX" > /etc/issue

rm -f /etc/netplan/00-installer-config.yaml
sed -e "s/IP_SUFFIX/$IP_SUFFIX/" $BASE/01-osism.yaml > /etc/netplan/01-osism.yaml
sed -e "s/IP_SUFFIX/$IP_SUFFIX/" -e "s/HOST/$SYSTEM_HOSTNAME/" $BASE/frr.conf > /etc/frr/frr.conf
cp $BASE/daemons /etc/frr/
cp $BASE/05-dummy0.netdev /etc/systemd/network/

netplan apply
systemctl restart frr
