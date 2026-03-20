#!/bin/bash

# --- Config ---
ALERT_EMAIL="thomas.halling1999@gmail.com"
LOGFILE="/var/log/disk_usage.log"
THRESHOLD_WARN=80
THRESHOLD_CRIT=90

# --- Check ---
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$disk_usage" -gt "$THRESHOLD_CRIT" ]
then
	status="CRITICAL"
elif [ "$disk_usage" -gt "$THRESHOLD_WARN" ]
then
	status="WARNING"
else
	status="OK"
fi

# --- Log ---
echo "$(date '+%Y-%m-%d %H:%M:%S') | $status | Disk usage: $disk_usage%" >> "$LOGFILE"

# --- Alert ---
if [ "$status" = "WARNING" ] || [ "$status" = "CRITICAL" ]; then
	echo -e "Subject: [$status] Disk Usage Alert\n\nDisk usage on $(hostname) is at $disk_usage%.\nStatus: $status\nTime: $(date)" | msmtp "$ALERT_EMAIL"
fi

# --- Report ---
echo "Date/time: $(date)"
echo "Disk Usage Report"
echo "-----------------"
echo "File system is at $disk_usage% usage"
echo "Threshold: 80%"
echo "Status: $status"


