#!/bin/bash
#Script to add checks on nodes(linux)

#path to the monitors check-file.
path_op5_commands="/etc/nrpe.d/op5_commands.cfg"

#Read the new checks
while read new_check
do

#Variable to check  if new check is present, changed, or new.
exists_nr=0
#Variable to check if a restart should occur or not.
restart_value=0

	#Strips out the new check's command-name
	new_check_command=$(echo "$new_check" | awk -F] '{print $1}'|awk -F[ '{print $2}')

		#Read the existing checks
		while read existing_check
		do
			#Strips out the existing check command-name
			existing_check_command=$(echo "$existing_check" | awk -F] '{print $1}'|awk -F[ '{print $2}')

			#If new check command-name equals existing check command-name..
			if [ "$new_check_command" == "$existing_check_command" ];
			then
				#..check if the whole new check is equal to the existing.
				if [ "$new_check" == "$existing_check" ];
				then
					#If it is, increase $exists_nr with 1.
					exists_nr=$(($exists_nr + 1 ))
				#If not, it means the new check has different values. 
				else
					#Therefore, decrease $exists_nr with 1..
					exists_nr=$(($exists_nr - 1 ))
					#.. and sets the $existing_check to $delete_check..
					delete_check=$existing_check_command
					#.. and $new_check to $add_check
					add_check=$new_check
				fi
			else
				#If new checks command is not equal to existing command (which means the new check does not exist with different parameters)..
				#.. sets $exists_nr with plus 0.
				exists_nr=$(($exists_nr + 0 ))
				#Sets $add_check to $new_check
				add_check=$new_check

			fi
		done < /etc/nrpe.d/op5_commands.cfg

	#If $exists_nr is greater then 0..
	if [ $exists_nr -gt 0 ];
	then
		#Print out that the check is already present.
		echo "The check, $new_check, is already present."
	#Or if $exists_nr is lower then 0..
	elif [ $exists_nr -lt 0 ];
	then
		#Print out that the check is present but has different values.
		echo "The check $new_check is present but has different values. Deleting old and adding new."
		#And delete the line which is the existing one, with old values.
		sed -i "/$delete_check/ d" $path_op5_commands
		#And add the new one, with the new values.
		$(echo "$add_check" >> "$path_op5_commands" )
		#Increase $restart_value with 1.
		restart_value=$(($restart_value + 1 ))
	#Or if $exists_nr is equal to 0..
	elif [ $exists_nr -eq 0 ];
	then
		echo "The check $new_check has been added"
		#.. the new check is added.
		$(echo "$add_check" >> "$path_op5_commands")
		#And the $restart_value is increased with 1.
		restart_value=$(($restart_value + 1 ))
		#Add new script-file to local storage for the NRPE-scripts.
		script_name=`ls /mnt/scripts/`
                if [ -z "$script_name" ];
                then
                        echo "No script to upload."
                else
                        cp "/mnt/scripts/$script_name" /opt/plugins/
                        chmod +x /opt/plugins/"$script_name"
                fi
	else
		echo "Unknown error. $exist_nr"
	fi
done < /mnt/upload/checks.txt

#Check if the $restart_value is greater then 0..
if [ $restart_value -gt 0 ];
then
	#.. if so, restart nrpe. This means that a new check has been added, or an old one has been modified.
	service nrpe restart
fi

#If OP5_Commands = uploaded file; then report done.
counter=$(wc -l < /mnt/upload/checks.txt )
exist_value=0
while read new_check
do

        while read existing_check
        do
                if [ "$new_check" == "$existing_check" ];
                then
                        exist_value=$(($exist_value + 1 ))
                else
                        exist_value=$(($exist_value + 0 ))
                fi

        done < /etc/nrpe.d/op5_commands.cfg
done < /mnt/upload/checks.txt

if [ $exist_value -eq $counter ];
then
	if [ -f /mnt/done.txt ];
        then
		hostname=$(hostname -f)
		test=`cat /mnt/done.txt | grep "$hostname"`
		if [ "$hostname" == "$test" ];
		then
			echo "Hostname exist in /mnt/done.txt, nothing to do."
		else
	        	echo "All checks are present."
			echo "$hostname" >> /mnt/done.txt
		fi
	else
		echo "ERROR!The file /mnt/done.txt does not exist."
	fi
else
	echo "ERROR! All checks have not been added."
fi
