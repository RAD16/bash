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
	if [ $1 = "ls" ]; then
		echo " "
		echo "Notes Directory"
		echo "---------------"
		ls "$_notesdir"
		echo " "
		exit 0
	else
		_argfile="$_notesdir""$1"
		if [ -e "$_argfile" ]; then
			vis "$_argfile"
			exit 0
		else
			touch "$_argfile"
			echo "$_dateshort" >> "$_argfile"
			echo "---------" >> "$_argfile"
			vis "$_argfile"
			exit 0
		fi
	fi
fi

if [ ! -e "$_note" ]; then 
	touch "$_note"
	echo "$_datelong" >> "$_note"
	echo "======================" >> "$_note"
	vis "$_note"
	exit 0
fi

vis "$_note"
exit 0