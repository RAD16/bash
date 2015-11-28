#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_date=`date +%A_%b_%d,_%Y`

if [ ! -e "$_file" ]; then 
	touch "$_file"
	echo "Notes:" >> "$_file"
	echo "$_date" >> "$_file"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
