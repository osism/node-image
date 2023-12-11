#!/bin/bash

rundir="$(dirname $(readlink -f $0))"

echo "Entering $rundir directory"
cd $rundir || exit 1

if [ -z "$1" ];then
   echo "$0 <variant>"
   echo
   grep variant .zuul.yaml
   exit 1
fi

image_name="${1}"

set -x
set -e

cp variants/disk-layout-${image_name}.yml include.d/disk-layout.yml
cp variants/runcmd-${image_name}.yml include.d/runcmd.yml

pipenv install
pipenv run python3 render-user-data.py > user-data
# cloud-init schema --config-file user-data

./image-create.sh -r -a -k -u user-data -n jammy

mv ubuntu-autoinstall.iso ubuntu-autoinstall-${image_name}.iso
sha256sum ubuntu-autoinstall-${image_name}.iso > ubuntu-autoinstall-${image_name}.iso.CHECKSUM

