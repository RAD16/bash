#! /bin/bash

# ==== Cycle backups ====
# Cycle through old backups. Keep hourly backups up to three days, then keep one backup per day after that.
# cycle.bkp.sh:  Uses named daily directories e.g. "today," "yesterday," "day_before" etc. and cycles through them daily,

# systemd timer/service files should be configured such that cycle script only runs after backup script has finished and isn't running, so they don't run  simultaneously.

# TO DO: function that sends alerts and deletes old backups if backup disk space drops below certain threshold.

#----- Config variables -----
backup_dir="/root/soil"
backup_part="/dev/sda-whatev"
date=$(date +%Y-%m-%d_%T)

#======= script ========
# series of functions called by "main ()" function at bottom of script : 
    # main () {
    #   prep
    #  daycycle
    #  weekcycle
    #  cleanup
    # }

#----- error logger -----
logr () {
 logfile="/var/log/bkp/errlog/"$date".bkp.errlog"
  if [ -f $logfile ]; then
    echo $1 | tee -a $logfile
  else
    echo $1 | tee $logfile
  fi
}

#----- error code checker -----
check () {
  if [ $? -eq 0 ]; then
    echo "--> $1 -- done!"
  else
    logr "ERROR: $1 failed."
    exit 1
  fi
}

#----- function: mounts and checks backup partition -----
prep () {
# mount the bkp partition first
  echo "_Mounting backup directory 'Soil':"
# check if bkp dir is mounted
  if [ ! -d $backup_dir ]; then
     # Create bkp directory 
     echo "__Creating backup directory."
     mkdir $backup_dir
       check "create backup directory"
   fi

 # Mount bkp partition to directory. Mount nodev, noexec, nosuid
	mount_opt="-o nodev,nosuid,noexec"
   mount $mount_opt $backup_part $backup_dir
     check "mount backup directory"
}

#----- Function: cycle daily directories ----- 
daycycle () {
 # Recycle backups
	# one="SANDBOX/today.hourly"
	# two="SANDBOX/yesterday.hourly"
	# three="SANDBOX/daybefore.hourly"
	# WI="SANDBOX/dailies/days_1.daily"

one="/root/soil/today.hourly"
two="/root/soil/yesterday.hourly"
three="/root/soil/daybefore.hourly"
WI="/root/soil/dailies/days_1.daily"

		# Save daily backup
  keep=($(ls "$three" -1|tail -1))
	echo "$keep"
  echo "$three"/"$keep"
  echo "_Cycling through backups:"
  mv "$three"/"$keep" "$WI"
     check "saving day-3 backup"       
  rm -rf ${three}
     check "removing day-3 directory"

# make sure variables set such that the directory is renamed not moved into another directory. 
  mv "$two" "$three"
     check "day-2 renamed day-3"
  mv "$one" "$two"
     check "day-1 renamed day-2"
  mkdir "$one"
     check "create day-1 directory"
 echo "today folder: `ls "$one" -1 | wc -l`"
 echo "yesterday folder: `ls "$two" -1 | wc -l`"
 echo "daybefore folder: `ls "$three" -1 | wc -l`"
 }

#----- Function: cycle weekly directories -----
weekcycle () {
 # Save weekly backup  
	# WI="SANDBOX/dailies/days_1.daily"
  # WII="SANDBOX/dailies/days_2.daily"
  # weeks="SANDBOX/weeks.weekly"

	WI="/root/soil/dailies/days_1.daily"
	WII="/root/soil/dailies/days_2.daily"
	weeks="/root/soil/weeks.weekly"
	
  count_w1=($(ls "$WI" -1 | wc -l))
  count_w2=($(ls "$WII" -1 | wc -l))
  keep_week=($(ls "$WII" -1 | tail -l))
 echo "week 1 count is: $count_w1"
 echo "week 2 count is: $count_w2"
 if [ "$count_w1" -gt 7 ]; then
	 echo "week 2 has more than 7!"
	 echo "keeping: "$keep_week""
   mv "$WII"/"$keep_week" "$weeks"
    check "save weekly backup to weeks directory"
   rm -rf "$WII"
     check "remove days_2.daily directory"
   mv "$WI" "$WII"
     check " directory 'days_1.weekly' renamed 'days_2'"
   mkdir "$WI"
     check "create days_1 directory"
 else
   echo "No new weeklies"
 fi
  echo "Week 2 list: `ls "$WII"`"
  echo "Weeklies: `ls "$weeks"`"
}

#----- Function: unmount backup partitions -----
cleanup () {
 #umount partition
 umount -R $backup_dir
  if [ $? -eq 0 ]; then
    echo "directory unmounted"
    rm -rf $backup_dir
      check "remove backup directory"
  else
     echo "ERROR: unmount backup directory failed"
     exit 1
   fi
 }

 #----- MAIN set -----
 main () {
  prep
  daycycle
  weekcycle
  cleanup
}

#----- MAIN CALL -----
main
  check "geology"
