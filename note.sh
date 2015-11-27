#! /bin/bash

_file="~/notes/`date +%Y-%m-%d`"
_date=`date +%A_%b_%d`

if [[ ! -e $_file ]]; then 
	touch  ~/notes/`date +%Y-%m-%d` 
	echo "Notes:" >> ~/notes/`date +%Y-%m-%d` 
	cat "$_date" >> ~/notes/`date +%Y-%m-%d` 
fi

vim ~/notes/`date +%Y-%m-%d`

