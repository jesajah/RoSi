#!/bin/bash
#Script to add services for linux systems to the op5 monitor GUI.

#Read machines (hostnames) from file (machines)

machines=`cat /mnt/upload/hosts_op5.txt`

#For each $machine in $machines..
for machine in $machines
do
	#Read checks (full names for the checks)
	#example from /mnt/checks: command[users]=/opt/plugins/check_users -w 5 -c 10
	while read check
	do
		#Cutting of to the command_args, for example -w 5 -c 10
		command_args=$(echo $check | awk -F] '{print $1}'|awk -F[ '{print $2}')

		#Cutting of to the description of the service, for example Check Users.
		desc=$(echo "$command_args" | sed 's/_/\ /g')
		#Execute the op5 monitor API command to add new services, and using the variable for the hostname($machine), the service description ($desc), and the check_command_args ($command_args).
		try_check=`php /opt/monitor/op5/nacoma/api/monitor.php -t service -a show_object -n "$machine;$desc" -u monitor | grep check_command=`
		if [ ! -z "$try_check" ];
		then
			echo "The service $command_args is already present on node $machine."
		else
			echo "Adding $command_args to $machine."
			php /opt/monitor/op5/nacoma/api/monitor.php -t service -o template=default-service -o host_name="$machine" -o service_description="$desc" -o check_command=check_nrpe -o check_command_args="$command_args" -u monitor
		fi
	done < /mnt/upload/checks.txt

	#Add check-ping because it is not provided by NRPE.
	check_ping=`php /opt/monitor/op5/nacoma/api/monitor.php -t service -a show_object -n "$machine;PING" -u monitor | grep check_command=`
	if [ ! -z "$check_ping" ];
	then
		echo "The service check_ping is already present on $machine."
	else
		echo "Adding check_ping to $machine."
		php /opt/monitor/op5/nacoma/api/monitor.php -t service -o template=default-service -o host_name="$machine" -o service_description="$desc" -o check_command=check_ping -o check_command_args=100,20%\!500,60% -u monitor
	fi

	#Add check-ssh-server because it is not provided by NRPE.
	check_ssh=`php /opt/monitor/op5/nacoma/api/monitor.php -t service -a show_object -n "$machine;SSH Server" -u monitor | grep check_command=`
	if [ ! -z "$check_ssh" ];
	then
		echo "The service check_ssh is already present on $machine."
	else
		echo "Addinge check_ssh to $machine."
		php /opt/monitor/op5/nacoma/api/monitor.php -t service -o template=default-service -o host_name="$machine" -o service_description="SSH Server" -o check_command=check_ssh -o check_command_args=5 -u monitor
	fi
done
#Saving the configuration done by the API, which will then be presented on the op5 monitor WEB GUI.
php /opt/monitor/op5/nacoma/api/monitor.php -a save_config -u monitor
