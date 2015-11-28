#! /bin/bash

_note="${_notesdir}`date +%Y-%m-%d`"
_notesdir="$HOME/notes/"
_datelong=`date +%A,\ %b\ %d,\ %Y`
_dateshort=`date +%Y-%m-%d`

if [ $# -gt 1 ]; then 
	echo "Too many arguments!"
	exit 0
fi

if [ $# -eq 1 ]; then
	_argfile="$_notesdir""$1"
	if [ -e "$_argfile" ]; then
		vim "$_argfile"
	else
		touch "$_argfile"
		echo "$_dateshort" >> "$_argfile"
		echo "---------" >> "$_argfile"
		vim "$_argfile"
	fi
fi

if [ ! -e "$_note" ]; then 
	touch "$_note"
	echo "$_datelong" >> "$_note"
	echo "======================" >> "$_note"
	vim ~/notes/`date +%Y-%m-%d`
fi

vim ~/notes/`date +%Y-%m-%d`
