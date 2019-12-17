#!/bin/bash

COUNT_FILE=/run/media/persistent/count

update() {
   /usr/bin/swupdate-progress -r -w &
   /bin/mount /dev/${1} /mnt/swupdate
   swupdate-client -v /mnt/swupdate/compound-image.swu
   umount /mnt/swupdate
}

# start the test

COUNT=`cat $COUNT_FILE`
echo "Value of count is: $COUNT"

if [ -z $COUNT ]; then
   COUNT=1
   echo $COUNT > $COUNT_FILE
   echo "Value of count is: $COUNT in if.."

elif [ $COUNT -eq 1 ]; then
   COUNT=$((COUNT+1))
   echo $COUNT > count
   echo "update will be performed"

else

#TODO: check_update_status
#TODO: save_status

   echo "update will be performed in else"
   if [ $COUNT -gt 3 ]; then

#TODO  print_the status

      echo "COUNT is greater than 3 now"
   fi
fi
