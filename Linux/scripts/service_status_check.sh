#!/bin/bash

services="ssh cron tailscaled"

echo "Service Status Report"
echo "---------------------"

for service in $services
do
	if systemctl is-active "$service" >/dev/null 2>&1
	then
		status="RUNNING"
	else
		status="STOPPED"
	fi

	echo "$service: $status"
done

