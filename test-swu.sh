#!/bin/bash
  
COUNT_FILE=/run/media/persistent/count
OVERFLOW=3
increment_count()
{
   i=`read_count`

   if [ -z $i ]; then
      i=0
   fi
   i=$((${i}+1))
   echo $i > $COUNT_FILE
   read_count
}

read_count()
{
   cat $COUNT_FILE
}

update() {
   /usr/bin/swupdate-progress -r -w &
   /bin/mount /dev/${1} /mnt/swupdate
   swupdate-client -v /mnt/swupdate/update.swu
   umount /mnt/swupdate
}



# start the test

## check overflow
## update in else

COUNT=`read_count`
if [ -z $COUNT ]; then
   COUNT=`increment_count`
   echo "update() count =$COUNT"
   update

elif  [ $COUNT -lt $OVERFLOW -a -n "$COUNT" ] ; then
   COUNT=`increment_count`
   echo "update() count = $COUNT"
   update
   #TODO: check_update_status
   #TODO: save_status

else
   echo "Overflow exceeded"
fi
