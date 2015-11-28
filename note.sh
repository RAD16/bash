#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_fileprefix="$HOME/notes/"
_datelong=`date +%A,\ %b\ %d,\ %Y`
_dateshort=`date +%Y-%m-%d`

if [ $# -eq 1 ]; then
	_argfile="$#"
	touch "$_argfile"
	echo "$_dateshort" >> "$_argfile"
	vim "$_argfile"
fi

if [ ! -e "$_file" ]; then 
	touch "$_file"
	echo "$_datelong" >> "$_file"
	echo "======================" >> "$_file"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
