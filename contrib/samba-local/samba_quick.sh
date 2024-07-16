#!/bin/bash

BASE_DIR="$(readlink -f "$(dirname $0)/../../")"
cd $DIR || exit 1
echo
echo "Connections":
for ip in $(hostname -I);do
   echo " smbclient //${ip}/media --user=WORKGROUP/osism%osism"
done
echo
echo "Available images:"
for iso in *.iso;
do
   echo "/media/${iso}"
done
echo
set -x
exec docker run  \
  --name samba \
  --rm \
  -e USER="osism" \
  -e PASS="osism" \
  -v ${BASE_DIR}/contrib/samba-local/configuration:/etc/samba:rw \
  -v ${BASE_DIR}:/srv:ro \
  --network host \
  index.docker.io/dockurr/samba:latest
