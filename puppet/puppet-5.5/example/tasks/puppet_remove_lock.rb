#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'

# establish lcokfiles
lockfile = Open3.capture3('puppet config print agent_catalog_run_lockfile')[0].chomp
disabled_lockfile = Open3.capture3('puppet config print agent_disabled_lockfile')[0].chomp

# remove lockfile(s) if it exists
[lockfile, disabled_lockfile].each { |lock| File.delete(lock) if File.file?(lock) }
