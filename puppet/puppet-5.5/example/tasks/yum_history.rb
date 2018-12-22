#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'facter'

# block on windows
exit 0 unless Facter::Core::Execution.which('yum')

# grab output and then actual useful lines from stdout
stdout, stderr, status = Open3.capture3('yum history')
exit raise Puppet::Error, _("yum history command failed with error: #{stderr}") if status.exitstatus != 0
history_lines = stdout.lines.select { |line| line =~ /^\s+\d/ }

# read in param and set default value
params = JSON.parse(STDIN.read, symbolize_names: true)
display_lines = params[:display_lines].nil? ? 2 : params[:display_lines]

# keep display_lines within min and max range
display_lines = if display_lines < 3
                  2
                elsif display_lines > history_lines.length
                  history_lines.length - 1
                end

puts history_lines[0..display_lines]
