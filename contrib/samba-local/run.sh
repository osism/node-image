#!/bin/bash

DIR="$(readlink -f $(dirname $0))"
IMAGES_DIR="$(readlink -f "$DIR/../../")"
cd $DIR || exit 1
cp -f docker-compose.yml.template docker-compose.yml
sed -i "~s,CFG_DIRECTORY,$DIR," docker-compose.yml
sed -i "~s,MEDIA_DIRECTORY,${MEDIA_DIRECTORY:-$IMAGES_DIR}," docker-compose.yml

echo "---"
for ip in $(hostname -I);do
   echo " smbclient //${ip}/media --user=WORKGROUP/osism%osism"
done
echo "---"
docker compose up --remove-orphans 
