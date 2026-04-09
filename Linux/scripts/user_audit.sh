#!/bin/bash
user_list=$(cat /etc/passwd | grep "bin/bash" | awk -F ':' '{print $1}')

echo "Last logins for each user"
echo "-------------------------"



for user in $user_list
do
	last_login=$(last -R $user | head -n 1)
	if [ -z "$last_login" ]
	then
		echo "$user has never logged in"
	else
		echo $user
		echo "Last logged in: $(last -R $user | head -n 1 | awk '{print $3, $4, $5, $6}')"
		
	fi
done
