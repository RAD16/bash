#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_date=`date +%A_%b_%d,_%Y`

if [ -e "$_file" ]; then 
	echo "gwangy sauce!"
	vim "$_file"
else
	echo "empty sauce"
	touch "$_file"
	echo "Notes:" >> ~/notes/`date +%Y-%m-%d` 
	echo "$_date" >> ~/notes/`date +%Y-%m-%d` 
	vim ~/notes/`date +%Y-%m-%d`
fi


