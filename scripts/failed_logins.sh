#!/bin/bash

logfile="$1"

if [ -z "$logfile" ]
then
	echo "Usage: ./failed_logins.sh <logfile>"
	exit 1
fi

if [ ! -f "$logfile" ]
then
	echo "Error: '$logfile' does not exist or is not a regular file"
	exit 1
fi

failed_count=$(grep "Failed password" "$logfile" | wc -l)

top_attempts=$(grep "Failed password" "$logfile" | awk -F 'from ' '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -nr | head -5)

echo "SSH Log Report"
echo "--------------"
echo "File: $logfile"
echo ""
echo "Failed SSH attempts: $failed_count"

echo "Top IP Attackers"
echo "----------------"
echo "$top_attempts"
