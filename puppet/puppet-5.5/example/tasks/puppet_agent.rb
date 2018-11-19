#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'puppet'
require 'facter'

# initialize params
params = JSON.parse(STDIN.read)

# input checking
if !params['noop'].nil? && !params['no_noop'].nil? && params['noop'] && params['no_noop']
  raise Puppet::Error, _('Cannot specify both noop and no-noop for a Puppet Agent execution!')
end

# initialize puppet command based upon operating system
puppet_cmd = case Facter.value(:kernel)
             when 'windows' then ['C:\ProgramFiles\PuppetLabs\Puppet\bin\puppet']
             else ['sudo', '/opt/puppetlabs/puppet/bin/puppet']
             end

# establish flags and arguments for the command
puppet_cmd << ['agent', '-t', '--detailed-exitcodes']
# optional parameter flags and arguments
puppet_cmd << ["--server #{params['puppet_master']}"] unless params['puppet_master'].nil?
puppet_cmd << ["--environment #{params['environment']}"] unless params['environment'].nil?
puppet_cmd << ["--tags #{params['tags'].join(',')}"] unless params['tags'].nil?
puppet_cmd << ['--verbose'] unless params['verbose'].nil? || !params['verbose']
puppet_cmd << ['--debug'] unless params['debug'].nil? || !params['debug']
puppet_cmd << ['--noop'] if !params['noop'].nil? && params['noop']
puppet_cmd << ['--no-noop'] if !params['no_noop'].nil? && params['no_noop']

# process puppet cmd for usage
cmd = puppet_cmd.flatten.join(' ')

# run puppet command
_, stderr, status = Open3.capture3(cmd)

# exit code 0 is green and 2 is yellow or blue
case status.exitstatus
when 0, 2
  puts "Puppet agent command '#{cmd}' successfully orchestrated with status #{status}."
  exit 0
when 1 then exit raise Puppet::Error, _("Puppet agent command '#{cmd}' failed with status #{status}! Error was #{stderr}")
when 4, 6 then exit raise Puppet::Error, _("Puppet agent command '#{cmd}' had failures!")
else raise Puppet::Error, _("Puppet agent command '#{cmd}' had unknown exit code with status #{status}! Error was #{stderr}")
end
