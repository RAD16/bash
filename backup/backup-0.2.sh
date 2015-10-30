#! /bin/bash

#======== Backup script for server/owncloud =======

# Pair with systemd backup.service/backup.timer for hourly system snapshots. 

# backup-0.2: places all backups in a directory "today.hourly" to eventually be cycled by day into  "yesterday.hourly," "daybefore.hourly" (backup-cycle.sh script). 

# Increased security: mounts the backup partition, keeps it mounted only while backup is running, then unmounts it and removes the mount directory for added obscurity.

: '
 Directory tree: 
    /root/soil/
         today.hourly/
         yesterday.hourly/
         daybefore.hourly/
         days_4-10.daily/
         days_11-17.daily/
         weeks.weekly/
         seed
'

# TO DO: script that triggers deletion of old backups upon low disk space. 

#-----Variables-----
sync_opt="-naPh"   # remove 'n' (dry run) option when ready 
link="link-dest=${SEED}"
data="/files/to/back/up/"
backup_part="/dev/sda-whatever/"
mnt_opt="-o nodev,noexec,nosuid"     # -U 'uuid number here' 
backup_dir="/root/soil"
today="/root/soil/today.hourly/"
seed="/root/soil/seed"  # symlink to latest backup used by rsync to hardlink unchanged files
log="/var/log/bkp/"
errlog="/var/log/bkp/err/"
day=$(date +%Y-%m-%d)
date=$(date +%Y-%m-%d_%T)

#--------Script---------
# series of functions called by "main ()” at end of script:
    # main () {
    #   prep 
    #   backup
    #   cleanup
    # } 

echo "CarbonSinc:"
echo "backup scripted in BASH"
sleep 2

# error logger
logr () {
 if [ -f $errlog/$date.bkp.errlog ]; then
   echo $1 | tee -a  $errlog/${date}.bkp.errlog
   else
    echo $1 | tee $errlog/${date}.bkp.errlog 
 fi
}

# error code checker 
check () {
 if [ $? -eq 0 ]; then
   echo "$1 -- done!"
 else
   logr "ERROR: $1 failed"
   exit 1
 fi
}

# prep function: checks for/mounts needed directories
prep () {
# check if bkp dir is mounted
if [ ! -d $BDIR ]; then
     # Create bkp directory 
     mkdir $BDIR
      check "Create backup directory"
 fi
     # Mount bkp partition to directory. 
   mount $MNTOPT $BPART $BDIR
     check "Mount backup partition"
      
   # Check for daily directory
  if [ ! -d $TODAY ]; then
      # Create new directory if necessary.
     mkdir $TODAY    
      check "Create today's backup directory"
  fi   
#    chmod 700 $TODAY    
#     if [ $? -eq 0 ]; then
#       echo "Today's backup directory locked by root."
#     else
#       logr "ERROR: Failed to root lock today's backup directory."
#        exit 1
#     fi
#  chown root:root necessary? 
} 

# backup function: rsync snapshot backup
backup () {
# Run rsync bkp
if [ -h $SEED ]; then
  echo "Running rsync..."
  rsync $OPT $LINK $DATA $TODAY/$DATE.bkp > ${LOG}$DATE.bkp.log
    check "rsync backup"
# Remove symlink to previous backup
  rm -f $SEED
    check "remove previous seed file" 
# Symlink to new latest backup
  ln -s $TODAY/$DATE.bkp $SEED
    check " symlinking new seed file"
else 
  logr "ERROR - Could not locate latest bkp to hardlink. Symlink 'seed' file may need to be created." 
  exit 1
fi
}
 
# cleanup function: unmounts and removes directories for security
cleanup () { 
# Unmount bkp directory
  umount -R  $BDIR
     if [ $? -eq 0 ]; then
       echo "Backup directory unmounted successfully."       
       # Remove bkp directory
       rmdir  $BDIR
         check "remove backup directory"
     else
         logr "ERROR: Failed to unmount backup directory." 
          exit 1
     fi     
}

main () {
  prep 
  backup
  cleanup
}

 main
  check "CarbonSinc"
