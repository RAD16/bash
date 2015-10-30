!# /bin/bash

# i3Status display
# Returns the number of packages available for upgrade through pacman. 
# For accurate count, `pacman -Sy` will need to be run. 

#  append i3status output to the measure-net-speed’s one.
# the quote and escape magic is required to get valid
# JSON output, which is expected by i3bar (if you want
# colors, that is. Otherwise plain text would be fine).
# For colors, your i3status.conf should contain:
# general {
#   output_format = i3bar
# }

# i3 config looks like this:
# bar {
#   status_command measure-net-speed-i3status.bash
# }

# Model script
# i3status | (read line && echo $line && read line && echo $line && while :
# do
  # read line
  # dat=$(measure-net-speed.bash)
  # dat="[{ \"full_text\": \"${dat}\" },"
  # echo "${line/[/$dat}" || exit 1
# done)

i3status | (read line && echo $line && read line && echo $line && while :
do
	read line
	pkgs=`pacman -Sup 2> /dev/null`
	echo "Pkgs: $pkgs" || exit 1
done)

