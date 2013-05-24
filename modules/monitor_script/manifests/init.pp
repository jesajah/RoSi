## == Class: monitor_script

# Main class for monitor_script, define variables etc.

class monitor_script {

$script1 = '/usr/local/bin/add_hosts.sh'
$script1source = 'puppet:///modules/monitor_script/add_hosts.sh'
$script2 = '/usr/local/bin/add_services_linux.sh'
$script2source = 'puppet:///modules/monitor_script/add_services_linux.sh'

#Define in which order the subclasses should be executed

        class {'monitor_script::run_hosts': } ->
        class {'monitor_script::run_checks': }
#	class {'monitor_script::unmount': }
}

#Sending the script "add_hosts.sh" to the monitor and execute it if the fileserver it mounted.

 class monitor_script::run_hosts inherits monitor_script {

	Exec {
                path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
        }

	file {$script1:
		source	=> $script1source,
		mode	=> '755'
 	}

	exec {$script1:
		require	=> File[$script1],
		onlyif	=> 'test -f /mnt/upload/hosts_op5.txt'
 	}
 }

#Sending the script "add_services_linux.sh" to the monitor and execute it if the fileserver it mounted.

 class monitor_script::run_checks inherits monitor_script {

	Exec {
                path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
        }

	file {$script2:
		source	=> $script2source,
		mode	=> '755'	
 	}

	exec {$script2:
		require		=> File[$script2],
		onlyif		=> 'test -f /mnt/upload/checks.txt'
 	}
 }

#Unmounts the fileserver if it is mounted. Removes the file info_scripts, if it exist, which the WEB GUI created.

# class monitor_script::unmount {
#
#        Exec {
#                path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
#       }
#
	#exec {'rm -f /mnt/upload/hosts_op5.txt':
	#	onlyif	=> 'test -f /mnt/upload/hosts_op5.txt'
	#}
 #}
