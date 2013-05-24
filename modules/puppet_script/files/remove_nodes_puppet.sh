#!/bin/bash
#
#Remove node-def. from /etc/puppet/manifests/site.pp, gained from /mnt/done.txt

counter=$(wc -l < /mnt/upload/hosts_op5.txt )
exist_value=0
while read uploaded_node
do

        while read done_node
        do
                if [ "$done_node" == "$uploaded_node" ];
                then
                        exist_value=$(($exist_value + 1 ))
                else
                        exist_value=$(($exist_value + 0 ))
                fi

        done < /mnt/done.txt

done < /mnt/upload/hosts_op5.txt

if [ $exist_value -eq $counter ];
then

	if [ -d /mnt/archived_services_and_hosts ];
	then
		mv /mnt/upload/hosts_op5.txt /mnt/archived_services_and_hosts/hosts_op5_$(date +%F)_$(date +%T)
		mv /mnt/upload/checks.txt /mnt/archived_services_and_hosts/checks_$(date +%F)_$(date +%T)
	else
		mkdir -p /mnt/archived_services_and_hosts/
		mv /mnt/upload/hosts_op5.txt /mnt/archived_services_and_hosts/hosts_op5_$(date +%F)_$(date +%T)
	        mv /mnt/upload/checks.txt /mnt/archived_services_and_hosts/checks_$(date +%F)_$(date +%T)
	fi

	while read node
	do
		node_full="node '$node' { include nrpe }"
		sed -i "/$node_full/d" /etc/puppet/manifests/site.pp
		sed -i "/$node/d" /mnt/done.txt
	done < /mnt/done.txt
	#Deletes the uploaded script, if it is uploaded.
	script_name=`ls /mnt/scripts/`
        if [ -z "$script_name" ];
        then
	        echo "No script seems to be uploaded. Nothing to delete."
        else
	        rm -f "/mnt/scripts/$script_name"
        fi

else
	echo "The file /mnt/done.txt does not exist, which it should because this script is executed by its existence. It can also mean that the files are different, please wait 2-4 minutes."
fi
