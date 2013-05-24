#!/bin/bash
#
#Add nodes to puppet.
#Example output in /etc/puppet/manifests/site.pp
#node 'examplecomputer.example.com' {include example_module}
#


while read node
do
node_full="node '$node' { include nrpe }"
exist_value=0
	while read existing_node
	do
		if [ "$existing_node" == "$node_full" ]
		then
			exist_value=$(($exist_value + 1 ))
		else
			exist_value=$(($exist_value + 0 ))
		fi
	done < /etc/puppet/manifests/site.pp

if [ $exist_value -gt 0 ];
then
	echo "Node $node already exist."
elif [ $exist_value -eq 0 ];
then
	echo "Node $node added."
	echo "$node_full" >> /etc/puppet/manifests/site.pp
fi

done < /mnt/upload/hosts_op5.txt
