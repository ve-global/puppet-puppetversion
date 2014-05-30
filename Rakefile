require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
PuppetLint.configuration.fail_on_warnings = true

# Forsake support for Puppet 2.6.2 for the benefit of cleaner code.
# http://puppet-lint.com/checks/class_parameter_defaults/
PuppetLint.configuration.send('disable_class_parameter_defaults')
# http://puppet-lint.com/checks/class_inherits_from_params_class/
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

exclude_paths = [
    "pkg/**/*",
    "vendor/**/*",
    "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

desc "Run syntax, lint, and spec tests."
task :test => [
    :syntax,
    :lint,
    :spec,
]

desc "Run acceptance tests against all nodesets"
task :spec_acceptance do
  puppet_version = ENV['PUPPET_VERSION'] || '3.4.3'

  Dir.foreach('spec/acceptance/nodesets/') do |item|
    next if item == '.' or item == '..'
    if item.end_with?('.yml') && !item.eql?('default.yml') && item.include?('windows')
      name = item[0, item.length - 4]
      system "PUPPET_VERSION=#{puppet_version} BEAKER_set=#{name} BEAKER_debug=yes bundle exec rspec spec/acceptance"
    end
  end
end