#!/bin/bash

disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$disk_usage" -gt 90 ]
then
	status="WARNING"
elif [ "$disk_usage" -gt 80 ]
then
	status="CRITICAL"
else
	status="OK"
fi

echo "Disk Usage Report"
echo "-----------------"
echo "File system is at $disk_usage% usage"
echo "Threshold: 80%"
echo "Status: $status"
