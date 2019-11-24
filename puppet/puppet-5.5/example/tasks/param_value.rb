#!/opt/puppetlabs/puppet/bin/ruby
# @summary
#    Perform predetermined parameter value actions with sqlplus.
#
# @example
#    puppet task run example::param_value os_user=oracle action=set param_value=300 scope=spfile oracle_param=session_cached_cursors --nodes localhost.domain
#    puppet task run example::param_value os_user=oracle action=show oracle_param=session_cached_cursors --nodes localhost.domain
#
# @param os_user
#    OS user to run sqlplus as.
#
# @param oracle_param
#    Oracle parameter to perform the action on.
#
# @param param_value
#    The updated/modified value of the parameter. Required for 'set' action.
#
# @param scope
#    The scope of the Oracle parameter modification. Required for 'set' action.
#
# @param action
#    The action to perform with the parameter.
#
require 'open3'
require 'json'
require 'puppet'

# initialize params
params = JSON.parse(STDIN.read, symbolize_names: true)

# construct command based on action
command = case params[:action]
          # set action
          when 'set'
            # these are required params for the set action
            %i[param_value scope].each { |param| raise Puppet::Error, _("#{param} was not set!") if params[param].nil? }
            # alter the system value
            "/sbin/runuser -l #{params[:os_user]} -c \"echo 'alter system set #{params[:oracle_param]}=#{params[:param_value]} scope=#{params[:scope]};' | sqlplus -S / as sysdba\""
          # show action
          when 'show'
            # warn on useless params specified; has to be stdout since warn goes to stderr and is ignored
            %i[param_value scope].each { |param| puts "#{param} was set for a 'show' action and will be ignored." unless params[param].nil? }
            # show the system parameter value
            "/sbin/runuser -l #{params[:os_user]} -c \"echo 'show parameter #{params[:oracle_param]};' | sqlplus -S / as sysdba\""
          # somehow an invalid action was specified
          else raise Puppet::Error, _("#{params[:action]} is not a valid action or action was not set!")
          end

# if the action is 'set' we need to ensure the value is not above the maximum
if params[:action] == 'set'
  # check if setting sga or pga value and validate if so
  if params[:oracle_param] =~ %r{([sp]ga)_target}
    # grab output of max value
    max_output = Open3.capture2("/sbin/runuser -l #{params[:os_user]} -c \"echo 'show parameter #{Regexp.last_match(1)}_max_size;' | sqlplus -S / as sysdba\"")[0]

    # make target and max values proper floats
    targ_num = %r{(\d+)}.match(params[:param_value])[1].to_f
    begin
      max_num = %r{(\d+)[KMG]}.match(max_output)[1].to_f
    rescue NoMethodError
      raise Puppet::Error, _('There are issues with the current setting of the max_size in the Oracle database. Try the show action to help diagnose the Oracle issues.')
    end

    # prevent increasing the target value past the max value if requested
    raise Puppet::Error, _("The specified #{params[:oracle_param]} #{targ_num} is greater than the maximum value #{max_num}!") if targ_num > max_num
  end
end

# run sqlplus system command
stdout = Open3.capture2(command)[0]

# process result of command
case stdout
when %r{ERROR}, %r{not available} then raise Puppet::Error, _("'#{command}' failed! Error was #{stdout}")
else
  puts "'#{command}' successfully orchestrated."
  puts "Output was #{stdout}."
  # we are finished here unless we need to restart the database
  exit 0 unless params[:scope] == 'spfile' && params[:action] == 'set'
  puts 'Now restarting database to recognize modifications.'
end

# if we are here then it means a successful set was performed with scope spfile; therefore bouncing db
stdout = Open3.capture2("/sbin/runuser -l #{params[:os_user]} -c \"echo 'SHUTDOWN NORMAL;' | sqlplus -S / as sysdba\"")[0]
raise Puppet::Error, _("Database shutdown failed! Error was #{stderr}") unless stdout =~ %r{ORACLE instance shut down}

# we should probably bring the database back up
stdout = Open3.capture2("/sbin/runuser -l #{params[:os_user]} -c \"echo 'STARTUP;' | sqlplus -S / as sysdba\"")[0]

# process result of startup
case stdout
when %r{Database opened} then puts 'The database was successfully restarted.'
else raise Puppet::Error, _("Database startup failed! Error was #{stdout}")
end
