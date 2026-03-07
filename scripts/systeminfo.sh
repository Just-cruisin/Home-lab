#!/bin/bash
echo "System information"
echo "------------------"
echo "Hostname: " $(hostname)
echo "IP Address: $(hostname -I | awk '{print $1}')"

#Disk usage %
disk=$(df / | awk 'NR==2 {print $5}')

#Memory usgae %
mem=$(free | awk '/Mem:/ {printf("%.0f%%", $3/$2 * 100)}')

echo "Disk usage: $disk"
echo "Memory Usage: $mem"
echo "Uptime: $(uptime -p)"
