#!/bin/bash

# --- Config ---
ALERT_EMAIL="thomas.halling1999@gmail.com"
LOGFILE="/var/log/network_monitor.log"

echo "Network monitor"
echo "---------------"

while IFS= read -r host
do
	ping $host -c 1 -q > /dev/null 2>&1
	check=$?
	if [ "$check" -eq 0 ]
	then
		echo "$host is up"
		# --- Log ---
		echo "$(date '+%Y-%m-%d %H:%M:%S') | $host is up" >> "$LOGFILE"
	else
		echo "$host is down"
		echo -e "Subject: [$host] is down" | msmtp "$ALERT_EMAIL"
		# --- Log ---
		echo "$(date '+%Y-%m-%d %H:%M:%S') | $host is down" >> "$LOGFILE"
	fi


done < hosts.txt
