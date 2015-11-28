#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_date=`date +%A,\ %b\ %d,\ %Y`

if [ ! -e "$_file" ]; then 
	touch "$_file"
	echo "$_date" >> "$_file"
	echo "======================" >> "$_file"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
