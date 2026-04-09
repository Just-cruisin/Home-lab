#!/bin/bash

#Used to find the path of the script called
SCRIPT_DIR="$(dirname $0)"

echo "Hostname: $(hostname)"
echo "Time generated: $(date)"
echo ""
$SCRIPT_DIR/disk_usage.sh
disk_exit=$?
echo ""
$SCRIPT_DIR/service_status_check.sh
service_exit=$?
if [ "$service_exit" -eq 0 -a "$disk_exit" -eq 0 ]
then
	echo "All systems OK"
else
	echo "Issues detected"
fi
