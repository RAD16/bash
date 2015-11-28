#! /bin/bash

_file="$HOME/notes/`date +%Y-%m-%d`"
_notesdir="$HOME/notes/"
_datelong=`date +%A,\ %b\ %d,\ %Y`
_dateshort=`date +%Y-%m-%d`

if [ $# -gt 1 ]; then 
	echo "Too many arguments!"
	exit 0
fi

if [ $# -eq 1 ]; then
	_argfile="$_notesdir"$1"
	if [ -e "$_argfile" ]; then
		vim "$_argfile"
	else
		touch "$_argfile"
		echo "$_dateshort" >> "$_argfile"
		echo "---------" >> "$_argfile"
		vim "$_argfile"
	fi
fi

if [ ! -e "$_file" ]; then 
	touch "$_file"
	echo "$_datelong" >> "$_file"
	echo "======================" >> "$_file"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
