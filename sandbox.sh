#! /bin/bash 

# script that sets and resets the development environment for my backup scripts.

#   ----Sandbox directory tree:
 ./sandbox/
   default/
   data.sample/
   test/
   log/
   

SBOX="/root/home/herbivore/builds/sandbox/"
DEF="$SBOX/default"

populate() {
  if [ $1 ! -d ]; then
   echo "Not a directory. Enter a directory to populate."
   exit 1
  fi
 
  mkdir "$1"/today.hourly "$1"/yesterday.hourly "$1"/day before.hourly "$1"/days_4-10 "$1"/days_11-17
  echo "$1 populated with these dirs:"
  ls $1
  tdy="$1/today.hourly/"
  yes="$1/yesterday.hourly"
  db="$1/daybefore.hourly"
   fill () {
    c=$(ls $1 -1 | wc -l) 
    d=$(date +%Y-%m-%d_%T)
    while [ $c -lt 10 ];  do 
     c=$(ls $1 -1 | wc -l)
     d=$(date +%Y-%m-%d_%T)
     touch $1/$d.smpl.bkp
     sleep 1
     done
   }
 
 # fill error handler
   fill_error() {
   if [ $? = 0 ]; then
     echo " "
    else
       $1 = 1
   fi
   }
   
 # fill directories
  fill $db
    fill_err db_err
  fill $yes
    fill_err yes_err
  fill $tdy
    fill_err tdy_err
  
  # report out
  echo $tdy "populated with these files:"
  ls $tdy
  
  echo $yes "populated with these files:"
  ls $yes
  
  echo $db "populated with these files:"
  ls $db
  
  exit 0
}

 default () {
if [ ! -d $DEF ]; then
 mkdir $DEF
 populate $DEF
 elif [ -d ${DEF}/today.hourly ];
 echo "Default directory exists and is populated!"
fi  
}
 
 cp_over () {
   rm -rf $SBOX/test
   cp -rf $DEF $SBOX/test
 }
 
 main () {
  default
  cp_over
 }

main
