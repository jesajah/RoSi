#!/bin/bash


#Read machines (hostnames) from file (machines)
while read machine;
do
	echo $machine
	#Read checks (full names for the checks)
	#command[users]=/opt/plugins/check_users -w 5 -c 10
	while read check
	do
		full_check=$(cat checks | awk -F] '{print $1}'|awk -F[ '{print $2}')
		while read current_check in $checks_ripped
		do
			#echo $current_check
			command_args=$(echo $current_check | awk -F] '{print $1}'|awk -F[ '{print $2}')
			desc=$(echo $command_args | sed s/_/\ /)
			php /opt/monitor/op5/nacoma/api/monitor.php -t service -o template=default-service -o host_name="$machine" -o service_description="$desc" -o check_command=check_nrpe -o check_command_args=$command_args -u monitor
		done
	done < /mnt/checks

done < /mnt/machines
php /opt/monitor/op5/nacoma/api/monitor.php -a save_config -u monitor

