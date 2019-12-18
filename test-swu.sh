#!/bin/bash
DEV="sda1"
COUNT_FILE=/run/media/persistent/count
SYSTEM_FILE=/run/media/persistent/system
OVERFLOW=6
KERNEL_A="itbImageA"
KERNEL_B="itbImageB"
ROOTFS_A="2"
ROOTFS_B="3"

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
root@imx8mqevk-mel:~# cat /run/media/persistent/test-swu.sh                                             
#!/bin/bash
DEV="sda1"
COUNT_FILE=/run/media/persistent/count
SYSTEM_FILE=/run/media/persistent/system
OVERFLOW=6
KERNEL_A="itbImageA"
KERNEL_B="itbImageB"
ROOTFS_A="2"
ROOTFS_B="3"

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
   /bin/mount /dev/sda1 /mnt/swupdate
   swupdate-client -v /mnt/swupdate/compound-image.swu
   umount /mnt/swupdate
}

read_system_id () {
   cat $SYSTEM_FILE
}
write_system_id () {
   echo $1 > $SYSTEM_FILE
}

##############
# Tests if Rootfs and Kernel are updated successfully.
#
# Contains bootloader specific reads of bootloader environment.
#
# Called by: validate-system_update
#
# Takes: No arguments
#
# Returns: 0 => Success, 1 => Failed
#
check_compound_update () {
   KERNEL_FILE=$(fw_printenv | grep ^kernelfile |  sed 's/.*=//')   
   ROOTFS_ID=$(fw_printenv | grep ^part |  sed 's/.*=//')

   SYSTEM_ID=`read_system_id`

   if   [ "$SYSTEM_ID" = "A" -a "$KERNEL_FILE" = "$KERNEL_A" -a "$ROOTFS_ID" = "$ROOTFS_A" ] ; then
      echo "0"
   elif [ "$SYSTEM_ID" = "B" -a "$KERNEL_FILE" = "$KERNEL_B" -a "$ROOTFS_ID" = "$ROOTFS_B" ] ; then
      echo "0"
   else
      echo "1"
   fi
}

############
# 

validate_system_update () {

   SYSTEM_ID=`read_system_id`

   # if system_id is NULL || system_id is A
   if [ -z "$SYSTEM_ID" -o "$SYSTEM_ID" = "A" ]; then
      write_system_id "B"
      COMPOUND_UPDATE_STATUS=`check_compound_update`
   elif [ $SYSTEM_ID = "B" ]; then
      write_system_id "A"
      COMPOUND_UPDATE_STATUS=`check_compound_update`
   else
      echo "ERROR! Should never get here! Some unexpected thing written in system file!"
   fi

   # return status to main
   echo "$COMPOUND_UPDATE_STATUS"
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
   STATUS=`validate_system_update`

   if [ $STATUS -eq 0 ] ; then
      echo "Compound Update Successful!"
   else
      echo "Compound Update Failed!" 
      #TODO: Can define status 1 & 2, to indicate successful kernel/rootfs update but failed compound ue
   fi

   #TODO: save_status
   update

else
   echo "Overflow exceeded"
fi
