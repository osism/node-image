#!/bin/bash

boot_device="$(efibootmgr -v|awk '/Boot[0-9A-F]*?.*ubuntu\s+HD\(/{a=gensub(/Boot(....)\*?.*/,"\\1","g",$1);printf("%s", a);}')"
current_boot_order="$(efibootmgr | awk '/BootOrder:/{print $2}')"

if [ "$(echo "$boot_device" | wc -l)" -ne 1 ];then
   echo "WARNING: Unable to find exactly a single suitable boot device, not setting the boot order"
   if [ "$1" = "auto" ]; then
      echo "INFO: Shutdown system now"
      shutdown -h now
      exit 0
   fi
fi

echo "INFO: change boot order, add installed disk as first device!"
new_boot_order="$(echo "${boot_device},${current_boot_order}"|sed '~s/\,i*$//g;~s, *,,g')"
efibootmgr -v -D -o "${new_boot_order}"
ret="$?"

if [ "$1" = "auto" ];then
   if [ "$ret" = "0" ]; then
      shutdown --reboot now
      echo "INFO: Rebootsystem now"
   else
      echo "INFO: Shutdown system now"
      shutdown -h now
      exit 0
   fi
fi
