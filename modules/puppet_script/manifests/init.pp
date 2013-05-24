## == Class: pupppet_script

class puppet_script {

$script1 = '/usr/local/bin/add_nodes_puppet.sh'
$script1source = 'puppet:///modules/puppet_script/add_nodes_puppet.sh'
$script2 = '/usr/local/bin/remove_nodes_puppet.sh'
$script2source = 'puppet:///modules/puppet_script/remove_nodes_puppet.sh'

Exec {
	path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
}

#Define in which order the subclasses should be executed

        class {'puppet_script::add_nodes': } ->
        class {'puppet_script::remove_nodes': }
}

class puppet_script::add_nodes inherits puppet_script
{
	file {$script1:
		source	=> $script1source,
		mode	=> '755'
 	}

	exec {$script1:
		require	=> File[$script1],
		onlyif	=> 'test -f /mnt/upload/hosts_op5.txt'
 	}
}

class puppet_script::remove_nodes inherits puppet_script
{
	file {$script2:
		source	=> $script2source,
		mode	=> '755'
 	}
	
	file {'/mnt/test.txt':
		mode	=> '766',
		source	=> '/mnt/done.txt'
	}

	exec {$script2:
		subscribe	=> File['/mnt/test.txt'],
		refreshonly	=> true
 	}
}
