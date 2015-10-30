#! /bin/bash

# Backup script for server/owncloud: hourly system snapshots.

# Increases security by mounting the backup partition only while backup is running, then unmounting it and removing the mount directory for added obscurity.

# Recycle old backups: separate script(s) moves last backup from each daily directory older than  three days into a per week directory, then removes the daily directory. Goal is to keep hourly backups for three days, then, 1 backup per day beyond that up to ten days. Maybe dailies into a per week folder, where after a month, one backup per week is moved into a per month or archive folder. Run via systemd timer once a day after final hourly backup of the day has run. Configure systemd such that recycle script can only run when backup script has finished. 

# TO DO: script that triggers deletion of old backups upon low disk space. 


## Should full server backup include hardlinks to owncloud files separated and put somewhere more easily accessible? Would complicate recycle script bc then I'd have to seek out that separate backup location. I think don't do: bkp is for emergency and versioning, will rarely need to access backups.

#-----Config vars-----

OPT="-aPh" 
LINK="link-dest=${FLASH}"
DATA=
BPART= # partition name or -U uuid whichever is more secure
MNTOPT="-o nodev,noexec,nosuid"     # -U 'uuid number here' 
BDIR="/root/thunder"
DAILY="/root/thunder/$DAY/"
BKP="/root/thunder/$DAY/$DATE/"
FLASH="/root/thunder/flash"
LOG="/var/log/bkp/"
ERRLOG="/var/log/bkp/err/"
DAY=`date "+%Y-%m-%d"`
DATE=`date "+%Y-%m-%d_%T"`

#------Script--------

# check if bkp dir is mounted
if [ ! -d "${BDIR}" ]; then
     # Create bkp directory 
     mkdir $BDIR
     if [ $? -eq 0 ]; then
       echo "Backup directory created."
       else
         echo "ERROR: Failed to create backup directory." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
      fi
   else
     # Mount bkp partition to directory. 
     mount $MNTOPT $BPART $BDIR
       if [ $? -eq 0 ]; then
         echo "Backup partition mounted successfully."
        else
         echo "ERROR: Failed to mount backup partition." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
      fi
fi 

# Check that bkp partition is not mounted by looking for latest backup 
if [ ! -e "${FLASH}" ]; then
   echo "ERROR - Could not locate latest bkp to hardlink. Symlink 'flash' file may need to be created. Error 1." > ${ERRLOG}${DATE}.bkp.errlog
   exit 1
   # Check for daily directory
  elif [ ! -d "${DAILY}" ]; then
      # Create new directory if necessary. Make sure it's chmod 700, if not, do it.
     mkdir $DAILY    
      if [ $? -eq 0 ]; then
        echo "Today's backup directory created."
        chmod 700 $DAILY #chown root:root ???
       else
         echo "ERROR: Failed to create daily backup directory." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
      fi
fi 


# Run rsync bkp
if [ -e "$FLASH" ]; then
  rsync $OPT $LINK $DATA ${DAILY}$DATE.bkp > ${LOG}$DATE.bkp.log
    if [ $? -eq 0 ]; then
       echo "Flash backup created."
       else
         echo "ERROR: Failed to create flash backup." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
     fi
# Remove symlink to previous backup
  rm -f $FLASH
    if [ $? -eq 0 ]; then
       echo "Previous backup symlink removed."
       else
         echo "ERROR: Failed to remove previous backup symlink: flash." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
    fi
# Symlink to new latest backup
  ln -s ${DAILY}$DATE.bkp $FLASH
    if [ $? -eq 0 ]; then
       echo "Symlink 'flash' to new backup created."
       else
         echo "ERROR: Failed to create symlink to new backup." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
    fi
# NO TO THIS: bkp directory is already root chmod 700. recursively 700ing rest of backup will make restoring a nightmare.  # chmod 700 the bkp if necessary
# chmod 700 ${DAILY}$DATE

# Unmount bkp directory
  umount -R  $BDIR
      if [ $? -eq 0 ]; then
       echo "Backup directory unmounted successfully."
       else
         echo "ERROR: Failed to unmount backup directory." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
      fi
 else 
  echo "ERROR - Could not locate latest bkp to hardlink. Symlink 'flash' file may need to be created. Error 2." > ${ERRLOG}${DATE}.bkp.errlog
  exit 1
fi
  
if [ -d "${DAILY}" ]; then
     echo "SECURITY ERROR - Couldn't unmount bkp partition. Error 3." > ${ERRLOG}${DATE}.bkp.errlog
     exit 1
   else
     # Remove bkp directory
     rmdir $BDIR
      if [ $? -eq 0 ]; then
       echo "Backup directory removed."
       else
         echo "ERROR: Failed to remove backup directory." > ${ERRLOG}${DATE}.bkp.errlog
         exit 1
      fi 
fi
# Done