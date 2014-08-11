source ENV['GEM_SOURCE'] || "http://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.4.0'
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper", "0.4.1"
  gem "specinfra", '~> 1.11.0'
  gem "winrm"
  gem 'kitchen-vagrant',
    :git => 'https://github.com/afiune/kitchen-vagrant',
    :ref => 'WinRM'
  gem 'test-kitchen', :path => '/Users/liamjbennett/Dev/forks/test-kitchen'
  gem 'kitchen-puppet', :path => '/Users/liamjbennett/Dev/public/kitchen-puppet'
  gem 'librarian-puppet'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
