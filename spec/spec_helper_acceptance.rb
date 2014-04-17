require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'winrm'

include Serverspec::Helper::Windows
include Serverspec::Helper::WinRM

hosts.each do |host|
  case host['platform']
    when /windows/

      #version = ENV['PUPPET_VERSION'] || '3.4.3'

      install_puppet('3.4.3')

      #Because puppet_module_install doesn't create the directory if it's missing
      on host, 'mkdir -p /cygdrive/c/ProgramData/PuppetLabs/puppet/etc/modules'

      #Because the msi installer doesn't add Puppet to the environment path
      on host, %q{ echo 'export PATH=$PATH:"/cygdrive/c/Program Files (x86)/Puppet Labs/Puppet/bin"' > /etc/bash.bashrc }

    else
      install_puppet
  end
end

UNSUPPORTED_PLATFORMS = ['Suse','AIX','Solaris']

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    puppet_module_install(:source => proj_root, :module_name => '')
    forge_repo = '--module_repository=http://forge.puppetlabs.com'

    hosts.each do |host|

      c.host = host

      endpoint = "http://127.0.0.1:5985/wsman"
      c.winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => 'vagrant', :pass => 'vagrant', :basic_auth_only => true)
      c.winrm.set_timeout 300

      on host, puppet(host, 'module','install', forge_repo, 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet(host, 'module', 'install', forge_repo, 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet(host, 'module', 'install', forge_repo, 'puppetlabs-inifile'), { :acceptable_exit_codes => [0,1] }
      on host, puppet(host, 'module', 'install', forge_repo, 'stahnma-puppetlabs_yum'), { :acceptable_exit_codes => [0,1] }
      on host, puppet(host, 'module', 'install', forge_repo, 'opentable-altlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end