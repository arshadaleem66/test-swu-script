#!/bin/bash

update() {
   /usr/bin/swupdate-progress -r -w &
   /bin/mount /dev/${1} /mnt/swupdate
   swupdate-client -v /mnt/swupdate/compound-image.swu
   umount /mnt/swupdate
}

# start the test

COUNT=cat count
if [[ $COUNT -eq 1 ]] then
   echo 2 > count
   update
else
   check_update_status
   save_status
   update
   if (overflowed the count)
      print_the status
   fi
fi
