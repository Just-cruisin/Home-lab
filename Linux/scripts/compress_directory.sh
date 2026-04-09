#!/bin/bash

# This script is used to compress a directory and save it to a backup location 

directory="$1"

if [ -z "$directory" ]
then
	echo "Usage: ./compress_directory.sh <directory>"
	exit 1
fi

if [ ! -d "$directory" ]
then
	echo "Error: $directory does not exist or is not a directory"
	exit 1
fi

backup_name="$(basename $directory)_$(date +%Y-%m-%d)"

tar -czf /home/tom/Documents/backups/$backup_name.tar.gz $directory

find /home/tom/Documents/backups -mtime +7 -delete

echo "Directory: $directory compressed!"
