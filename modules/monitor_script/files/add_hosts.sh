#!/bin/bash
#
#Script to add hosts to op5 via CLI
unset $hostnames
unset $hostname

#Read the file with the hostnames
hostnames=`cat /mnt/upload/hosts_op5.txt`

existing_hostnames=`cat /opt/monitor/etc/hosts.cfg | grep host_name | awk '{print $2}'`

#Loops all hostnames in $hostnames and puts one after one in $hostname
for hostname in $hostnames
do
existing_value=0
	for existing_hostname in $existing_hostnames
	do
		if [ "$existing_hostname" == "$hostname" ];
		then
			existing_value=$(($existing_value + 1))
		else
			existing_value=$(($existing_value + 0))
		fi
	done
	if [ $existing_value -eq 0 ];
	then
		#Add host to op5 via op5 monitor API and saves the $hostname in a temp-file.
		php /opt/monitor/op5/nacoma/api/monitor.php -t host -o host_name=$hostname -o address=$hostname -o template=default-host-template -u monitor
		echo $hostname >> /tmp/hostnames
		save=1
	elif [ $existing_value -gt 0 ];
	then
		echo "the node $hostname does already exist."
	else
		echo "Unknown error."
	fi
done

if  [ $save -eq 1 ];
then
	#Saving the configuration done by the op5 monitor API, which will then be presented on the WEB GUI.
	php /opt/monitor/op5/nacoma/api/monitor.php -a save_config -u monitor
else
	echo "Nothing to save. All hosts are present."
	exit 0;
fi


