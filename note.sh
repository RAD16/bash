#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_fileprefix="$HOME/notes"
_date=`date +%A,\ %b\ %d,\ %Y`

if [ $# -eq 1 ]; then
	vim "$_fileprefix/$#"
fi

if [ ! -e "$_file" ]; then 
	touch "$_file"
	echo "$_date" >> "$_file"
	echo "======================" >> "$_file"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
