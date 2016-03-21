require 'spec_helper'

describe 'puppetversion', :type => :class do

  context 'when trying to ensure the puppet version is 3.4.2 on ubuntu/debian' do
    let(:facts) { {
        :osfamily        => 'debian',
        :lsbdistid       => 'ubuntu',
        :lsbdistcodename => 'squeeze',
        :agent_rundir    => '/var/lib/puppet/run',
        :rubyversion     => '1.9.3'
    } }

    let(:params) {{ :version => '3.4.2'}}

    it { should contain_package('puppet').with_ensure('3.4.2-1puppetlabs1') }

    it { should contain_package('puppet-common').with_ensure('3.4.2-1puppetlabs1').that_requires('Apt::Source[puppetlabs]') }

    it { should contain_apt__source('puppetlabs').with_location('http://apt.puppetlabs.com').with_repos('main dependencies').with_key('47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30').with_key_content(/----BEGIN PGP PUBLIC KEY BLOCK-----/).that_requires('Exec[rm_duplicate_puppet_source]') }

    it { should contain_exec('rm_duplicate_puppet_source').with_path('/usr/local/bin:/bin:/usr/bin').with_command('sed -i \'s:deb\ http\:\/\/apt.puppetlabs.com\/ precise main::\' /etc/apt/sources.list').with_onlyif('grep \'deb http://apt.puppetlabs.com/ precise main\' /etc/apt/sources.list') }

    it { should contain_ini_setting('update init.d script PIDFILE to use agent_rundir').with_path('/etc/init.d/puppet').with_ensure('present').with_section('').with_setting('PIDFILE').with_value('"/var/lib/puppet/run/${NAME}.pid"').with_require('Package[puppet]') }
  end

  context 'when trying to ensure the puppetversion with an invalid rundir on ubuntu/debian' do
    let(:facts) { {
        :osfamily        => 'debian',
        :lsbdistid       => 'ubuntu',
        :lsbdistcodename => 'squeeze',
        :agent_rundir    => 'xxxxx',
        :rubyversion     => '1.9.3'
    } }

    let(:params) {{ :version => '3.4.2'}}

    it { expect { should contain_package('puppet') }.to raise_error(Puppet::Error, /not an absolute path/) }
  end

  context 'when trying to ensure the puppet version is 3.4.3 on ubuntu/debian' do
    let(:facts) { {
        :osfamily        => 'debian',
        :lsbdistid       => 'ubuntu',
        :lsbdistcodename => 'squeeze',
        :agent_rundir    => '/var/lib/puppet/run',
        :rubyversion     => '1.9.3'
    } }

    let(:params) {{ :version => '3.4.3'}}

    it { should contain_package('puppet').with_ensure('3.4.3-1puppetlabs1').that_requires('Apt::Source[puppetlabs]') }

    it { should contain_package('puppet-common').with_ensure('3.4.3-1puppetlabs1').that_requires('Apt::Source[puppetlabs]') }

    it { should contain_apt__source('puppetlabs').with_location('http://apt.puppetlabs.com').with_repos('main dependencies').with_key('47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30').with_key_content(/----BEGIN PGP PUBLIC KEY BLOCK-----/).that_requires('Exec[rm_duplicate_puppet_source]') }

    it { should contain_exec('rm_duplicate_puppet_source').with_path('/usr/local/bin:/bin:/usr/bin').with_command('sed -i \'s:deb\ http\:\/\/apt.puppetlabs.com\/ precise main::\' /etc/apt/sources.list').with_onlyif('grep \'deb http://apt.puppetlabs.com/ precise main\' /etc/apt/sources.list') }

    it { should contain_ini_setting('update init.d script PIDFILE to use agent_rundir').with_path('/etc/init.d/puppet').with_ensure('present').with_section('').with_setting('PIDFILE').with_value('"/var/lib/puppet/run/${NAME}.pid"').with_require('Package[puppet]') }
  end

  context 'when running Ruby >= 2.0.0 on Ubuntu/Debian' do
    let(:facts) do
      {
        :osfamily        => 'debian',
        :lsbdistid       => 'ubuntu',
        :lsbdistcodename => 'squeeze',
        :agent_rundir    => '/var/lib/puppet/run',
        :rubyversion     => '2.0.0'
      }
    end

    it do
      should contain_package('ruby-augeas')
        .with_ensure('present')
        .with_provider('gem')
        .with_install_options({'-v' => '0.5.0'})
    end

    it do
      should contain_package('pkg-config', 'libaugeas-dev')
        .with_ensure('present')
        .with_before('Package[ruby-augeas]')
    end
  end

  context 'when trying to ensure the puppet version is 3.4.2 on redhat/centos 6' do
    let(:facts) {{
      :osfamily                  => 'redhat',
      :operatingsystem           => 'centos',
      :os_maj_version            => '6',
      :architecture              => 'amd64',
      :pper_installed            => 'false',
      :operatingsystemmajrelease => '6'
    }}

    let(:params) {{ :version => '3.4.2'}}

    it { should contain_package('puppet').with_ensure('3.4.2-1.el6').that_requires('Class[puppetlabs_yum]') }

    it { should contain_class('puppetlabs_yum') }

  end

  context 'when trying to ensure the puppet version is 3.4.2 on centos 7' do
    let(:facts) {{
      :osfamily                  => 'redhat',
      :operatingsystem           => 'centos',
      :os_maj_version            => '7',
      :architecture              => 'amd64',
      :pper_installed            => 'false',
      :operatingsystemmajrelease => '7'
    }}

    let(:params) {{ :version => '3.4.2'}}

    it { should contain_package('puppet').with_ensure('3.4.2-1.el7').that_requires('Class[puppetlabs_yum]') }

    it { should contain_class('puppetlabs_yum') }

  end

  context 'when trying to ensure the puppet version is 3.4.2 on windows with default params' do
    let(:facts) {{
      :osfamily      => 'windows',
      :puppetversion => '3.4.1'
    }}

    let(:params) {{ :version => '3.4.2'}}

    it { should contain_file('UpgradePuppet script').with(
      'ensure' => 'present',
      'path'   => 'C:/Windows/Temp/UpgradePuppet.ps1'
    )}

    it { should contain_exec('create scheduled task').with(
      'command'     => 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File C:\Windows\Temp\ScheduledTask.ps1 -ensure present',
      'refreshonly' => 'true'
    )}
  end

  #TODO: test the param validation

end
