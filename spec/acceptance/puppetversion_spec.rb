require 'spec_helper_acceptance'

describe 'puppetversion', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  debian_relase = case fact('lsbmajdistrelease')
                    when '10'
                      'lenny'
                    when '12'
                      'squeeze'
                    when '13'
                      'wheezy'
                    else
                      'fubar'
                    end

  #TODO: add unless condition
  #TODO: add loop to test upgrades from all previous (>2.7) versions to latest

  context 'upgrade on ubuntu/debian', :unless => fact('osfamily').eql?('RedHat') do
    it 'should install the new version' do
      shell("wget http://apt.puppetlabs.com/pool/#{debian_relase}/main/p/puppet/puppet-common_3.4.2-1puppetlabs1_all.deb")
      shell("wget http://apt.puppetlabs.com/pool/#{debian_relase}/main/p/puppet/puppet_3.4.2-1puppetlabs1_all.deb")
      shell('dpkg -i puppet-common_3.4.2-1puppetlabs1_all.deb')
      shell('dpkg -i puppet_3.4.2-1puppetlabs1_all.deb')

      pp = <<-PP

        class { 'puppetversion':
          version => '3.4.3'
        }
      PP

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/etc/apt/sources.list') do
      it { should be_file }
      its(:content) { should_not match /http:\/\/apt\.puppetlabs\.com/ }
    end

    describe file('/etc/apt/sources.list.d/puppetlabs.list') do
      it { should be_file }
      its(:content) { should match /deb http:\/\/apt\.puppetlabs\.com precise main dependencies/ }
    end

    #TODO add test for pidfile fix

    describe package('puppet') do
      it { should be_installed.with_version('3.4.3-1puppetlabs1') }
    end
  end

  context 'upgrade on centos/redhat', :unless => fact('osfamily').eql?('Debian') do
    it 'should install the new version' do
      shell("yum install -y redhat-lsb")
      shell("rpm -e puppet")
      shell("wget http://yum.puppetlabs.com/el/#{fact('lsbdistrelease')}/products/#{fact('architecture')}/puppet-3.4.2-1.el#{fact('lsbmajdistrelease')}.noarch.rpm")
      shell("rpm -ivh puppet-3.4.2-1.el#{fact('lsbmajdistrelease')}.noarch.rpm")

      pp = <<-PP

        class { 'puppetversion':
          version => '3.4.3'
        }
      PP

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/etc/yum.repos.d/puppetlabs.repo') do
      it { should be_file }
    end

    describe package('puppet') do
      it { should be_installed.with_version('3.4.3-1') }
    end

  end

end