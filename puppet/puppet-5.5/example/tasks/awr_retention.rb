#!/opt/puppetlabs/puppet/bin/ruby
# @summary
#    Inspect or modify the AWR retention days for an Oracle instance.
#
# @example
#    puppet task run example::awr_retention os_user=oracle action=modify retention_days=30 --nodes hostname.domain
#    puppet task run example::awr_retention os_user=oracle action=show --nodes hostname.domain
#
# @param os_user
#    OS user to run sqlplus as.
#
# @param retention_days
#    The number of days to retain the AWR. Required for 'modify' action.
#
# @param action
#    Whether to show the current retention period or modify it.
#
require 'open3'
require 'json'
require 'puppet'

# initialize params
params = JSON.parse(STDIN.read, symbolize_names: true)

# construct command based on action
command = case params[:action]
          # modify action
          when 'modify'
            # this is a required param for the modify action
            raise Puppet::Error, _('retention_days was not set!') if params[:retention_days].nil?
            # create tempfile for script
            require 'tempfile'
            file = Tempfile.new(%w[script .sql])
            file.write("BEGIN\ndbms_workload_repository.modify_snapshot_settings (interval => 60,retention => #{params[:retention_days]}*24*60);\nEND;\n/")
            # flush buffer and allow oracle to read and execute
            file.rewind
            file.chmod(0o555)
            # alter the retention days
            "/sbin/runuser -l #{params[:os_user]} -c \ 'sqlplus -S / as sysdba @#{file.path}'"
          # show action
          when 'show'
            # warn on useless params specified; has to be stdout since warn goes to stderr and is ignored
            puts 'retention_days was set for a \'show\' action and will be ignored.' unless params[:retention_days].nil?
            # show the system parameter value
            "/sbin/runuser -l #{params[:os_user]} -c \"echo 'select extract(day from retention) RetentionDays from dba_hist_wr_control;' | sqlplus -S / as sysdba\""
          # somehow an invalid action was specified
          else raise Puppet::Error, _("#{params[:action]} is not a valid action or action was not set!")
          end

# run awr retention command
stdout = Open3.capture2(command)
# garbage collect tempfile if we used one
file.close! if params[:action] == 'modify'

# process result of command
case stdout
when %r{ERROR}, %r{not available} then raise Puppet::Error, _("'#{command}' failed! Error was #{stdout}")
else
  puts "'#{command}' successfully orchestrated."
  puts "Output was #{stdout}."
  exit 0
end
