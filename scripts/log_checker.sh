#!/bin/bash

LOGFILE=/var/log/compression.log

# --- Compress files olders than 7 days ---
while IFS= read -r logfile
do
	check=$(find $logfile -mtime +7)
	if [ -z "$check" ]
	then
		echo "No old logs"
	else
		gzip $logfile
		echo "$(date '+%Y-%m-%d %H:%M:%S') | $logfile compressed" >> "$LOGFILE"
	fi
	
	# --- Delete compressed files older than30 days ---
	old_file=$(find $logfile -mtime +30 -name "*.gz")
	if [ -z "$old_file" ]
	then
		echo "No old logs to delete"
	else
		rm $old_file
		echo "$(date '+%Y-%m-%d %H:%M:%S') | $old_file deleted" >> "$LOGFILE"
	fi


done < logs.txt
