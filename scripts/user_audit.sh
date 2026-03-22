#!/bin/bash
user_list=$(cat /etc/passwd | grep "bin/bash" | awk -F ':' '{print $1}')

for user in $user_list
do
	echo $user
	echo "Last logged in: $(last -R $user | head -n 1 | awk '{print $3, $4, $5, $6}')"
done
