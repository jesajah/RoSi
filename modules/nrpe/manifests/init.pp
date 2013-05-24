## == Class: nrpe

#Main class for NRPE, define variables etc
class nrpe (

)

#Defines how the subclasses should be executed

{
	class {'nrpe::mount': } ->
	class {'nrpe::install': } ->
	class {'nrpe::files': } ->
	class {'nrpe::service': } ->
	class {'nrpe::run_script': }
}

#Mounting the fileserver if NRPE's config-file is present.

 class nrpe::mount {
	Exec {
		path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
	}
        mount {'/mnt':
		device	=> 'fileserver.rosi.local:/share',
		fstype	=> 'nfs',
		ensure	=> 'mounted',
		options	=> 'defaults',
		atboot	=> 'false'
	}
}

#Makes sure that the dependencies of NRPE is installed, and then installs NRPE.

 class nrpe::install {
 
       package {'gnutls':
                ensure  => installed,
                #require => exec['mount -t nfs fileserver.rosi.local:/share /mnt']
        }

        package {'mysql':
                ensure  => installed,
                require => package['gnutls']
        }

        package {'postgresql':
                ensure  => installed,
                require => package['mysql']
        }

        package {'nrpe_nagiosplugins-2.13.1-release.x86_64':
                ensure  => installed,
                provider => rpm,
                source  => '/mnt/packages/nrpe-2.13-nagios_plugins-1.4.15-CentOS_6-2.13.1_x86_64.rpm',
                require => package['postgresql']
        }
}

#Disabling SElinux (should add an exception instead..).

 class nrpe::files {
	Exec {
		path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
	}

        exec {'setenforce 0':
		onlyif  => 'grep -c SELINUX=enforcing /etc/selinux/config',
        	before	=> file_line['remove_line']
	}

        file_line {'remove_line':
                path    => '/etc/selinux/config',
                line    => 'SELINUX=enforcing',
                ensure  => absent
        }

        file_line {'add_selinux_disabled':
                path    => '/etc/selinux/config',
                line    => 'SELINUX=disabled',
                require => file_line['remove_line']
        }

}

#Edit the NRPE conf to allow the op5 monitor to communicate with the node. Restart the service when the config-file is changed.

 class nrpe::service {

        file_line {'remove_hosts':
                path    => '/etc/nrpe.conf',
                line    => 'allowed_hosts=127.0.0.1',
                ensure  => absent,
                before	=> file_line['allowed_hosts']
	}

        file_line {'allowed_hosts':
                path    => '/etc/nrpe.conf',
                line    => 'allowed_hosts=127.0.0.1,139.139.139.4'
        }

	file {'/etc/nrpe.conf':
		source	=> 'puppet:///files/nrpe.conf'
	}

        exec {'service nrpe restart':
		path    	=> ['/sbin', '/bin','/usr/sbin', '/usr/bin' ],
		subscribe	=> File['/etc/nrpe.conf'],	
		refreshonly	=> true
	}
}

class nrpe::run_script {

$script1 = '/usr/local/bin/add_check_on_nodes.sh'
$script1source = 'puppet:///modules/nrpe/add_check_on_nodes.sh'

	Exec {
		path    => ['/sbin', '/bin','/usr/sbin', '/usr/bin' ]
	}

	file {$script1:
		source	=> $script1source,
		mode	=> '755'	
	 }

	exec {$script1:
		require		=> File[$script1],
                onlyif		=> 'test -f /mnt/upload/checks.txt'
 	}
}

