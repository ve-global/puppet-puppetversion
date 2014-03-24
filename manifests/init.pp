#
class puppetversion(
  $version = $puppetversion::params::version,
  $start_time = $puppetversion::params::start_time,
  $proxy_address = $puppetversion::params::proxy_address,
  $download_source = $puppetversion::params::download_source
) inherits puppetversion::params {

  case downcase($::osfamily) {
    'debian': {
      validate_absolute_path($::agent_rundir)

      $puppetPackages = ['puppet','puppet-common']

      exec { 'rm_duplicate_puppet_source':
        path    => '/usr/local/bin:/bin:/usr/bin',
        command => 'sed -i \'s:deb\ http\:\/\/apt.puppetlabs.com\/ precise main::\' /etc/apt/sources.list',
        onlyif  => 'grep \'deb http://apt.puppetlabs.com/ precise main\' /etc/apt/sources.list',
      }

      apt::source { 'puppetlabs':
        location    => 'http://apt.puppetlabs.com',
        repos       => 'main dependencies',
        key         => '4BD6EC30',
        key_content => template('puppetversion/puppetlabs.gpg'),
        require     => Exec['rm_duplicate_puppet_source']
      }

      package {$puppetPackages:
        ensure   => "${version}-1puppetlabs1",
        require  => Apt::Source['puppetlabs']
      }

      ini_setting { 'update init.d script PIDFILE to use agent_rundir':
        ensure  => present,
        section => '',
        setting => 'PIDFILE',
        value   => "\"${::agent_rundir}/\${NAME}.pid\"",
        path    => '/etc/init.d/puppet',
        require => Package['puppet'],
      }

    }
    'redhat': {

      class {'puppetlabs_yum':}

      package{ 'puppet' :
        ensure  => "${version}-1.el6",
        require => Class['puppetlabs_yum']
      }

    }
    'windows': {

      if $::puppetversion != $version {

        # Using powershell to uninstall and reinstall puppet because there is not workflow
        # support for inplace upgrades
        file { 'UpgradePuppet script':
          ensure  => present,
          path    => 'C:/Windows/Temp/UpgradePuppet.ps1',
          content => template('puppetversion/UpgradePuppet.ps1.erb')
        }

        # Using another powershell script to create a scheduled task to run the upgrade script.
        #
        # The scheduled_task resource is not being used here because there is no way to pass
        # local time to the start_time parameter. Using the strftime from stdlib will use the
        # time at catalog compilation (the time of the master) which will cause problems if you
        # clients run in a differne timezone to the master

        file { 'ScheduleTask script':
          ensure  => present,
          path    => 'C:/Windows/Temp/ScheduledTask.ps1',
          content => template('puppetversion/ScheduledTask.ps1.erb'),
          require => File['UpgradePuppet script']
        }

        exec { 'create scheduled task':
          command => 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\Windows\Temp\ScheduledTask.ps1 -ensure present',
          require => File['ScheduleTask script'],
          unless  => 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\Windows\Temp\ScheduledTask.ps1 -exists True'
        }

      } else {

        file { 'UpgradePuppet script':
          ensure => absent,
          path   => 'C:/Windows/Temp/UpgradePuppet.ps1',
        }

        # Yes we still have to exec to remove because scheduled_task { ensure => absent } doesn't work!
        exec { 'remove scheduled task':
          command => 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\Windows\Temp\ScheduledTask.ps1 -ensure absent',
          before  => File['ScheduleTask script'],
          onlyif  => 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\Windows\Temp\ScheduledTask.ps1 -exists True'
        }

        file { 'ScheduleTask script':
          ensure => absent,
          path   => 'C:/Windows/Temp/ScheduledTask.ps1',
        }
      }
    }
    default: {
      fail("This module does not support ${::osfamily}")
    }
  }
}