#! /bin/bash

# Cycle through old backups. Keep hourly backups up to three days, then keep one backup per day after that.

# systemd timer/service files should be configured such that recycle script only runs after backup script has finished and isn't running, so they don't run  simultaneously.

# TO DO: function that keeps dailies for two weeks, then moves one daily backup per week into a weekly directory.

# Keep backups in archive folder 'dailies’

DAYS=/root/thunder/dailies/
BDIR=/root/thunder
BPART=
MNTOPT=
LOG=/var/log/bkp/
ERRLOG=/var/log/bkp/errlog
DATE=`date "+%Y-%m-%d_%T"`

# mount the bkp partition before rest of script

# check if bkp dir is mounted
if [ ! -d "${BDIR}" ]; then
     # Create bkp directory 
     mkdir $BDIR
      if [ $? -eq 0 ]; then
        echo "Backup directory created."
       else
        echo "ERROR: Failed to create backup directory."
        exit 1
      fi
fi
     # continue

 # Mount bkp partition to directory. Mount nodev, noexec, nosuid
    mount $MNTOPT $BPART $BDIR
         if [ $? -eq 0 ]; then
        echo "Backup directory created."
       else
        echo "ERROR: Failed to create backup directory."
        exit 1
      fi

###


OLD=`find /root/thunder/ * -type d -maxdepth 0 -ctime +7`

KEEP=`ls "${OLD}" -1|tail -1` 

# If $OLD returns a name and not an executable directory, this won't work. May need to prefix the parent directory ls /root/thunder/${OLD}

# Not sure best way to move into Dailies dir: rsync, cp -all, or mv. Not sure if mv will hardlink, rsync can if told, as can cp -al but which command better/more efficient/faster? Any reason rsync too slow/overkill, or cp -al not robust enough?

rsync -aPh "${KEEP}" "${DAYS}" > ${LOG}${DATE}.bkp.cycl.log
     if [ $? -eq 0 ]; then
        echo "Backup directory created."
       else
        echo "ERROR: Failed to create backup directory."
        exit 1
      fi

&&
rm -rf "${OLD}"
     if [ $? -eq 0 ]; then
        echo "Backup directory created."
       else
        echo "ERROR: Failed to create backup directory."
        exit 1
      fi

 #umount partition
end