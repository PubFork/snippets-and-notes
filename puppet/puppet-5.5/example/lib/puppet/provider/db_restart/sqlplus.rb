require_relative '../sqlplus_helper.rb'

Puppet::Type.type(:db_restart).provide(:sqlplus, parent: Puppet::Provider::Sqlplus_Helper) do
  desc "SQLPlus provider for the db_restart type.

  This provider handles restarting for Oracle database instances."

  confine osfamily: :RedHat

  def self.instances
    []
  end

  def when
    :absent
  end

  def when=(value); end

  def restart
    startup = "#{@resource[:startup_option]};"
    shutdown = "SHUTDOWN #{@resource[:shutdown_option]};"

    case @resource[:apply]
    when :during
      Puppet.debug("Executing sqlplus #{shutdown} and #{startup} commands.")
      restart_db(shutdown, startup)
    when :finished
      Puppet.debug("Adding sqlplus #{shutdown} and #{startup} commands to ruby's at_exit handler.")
      pid = Process.pid
      at_exit { restart_db(shutdown, startup) if Process.pid == pid }
    end
  end

  def restart_db(shutdown_cmd, startup_cmd)
    Puppet.info('Shutting down Oracle DB instance.')
    sqlplus(shutdown_cmd)
    Puppet.info('Starting up Oracle DB instance.')
    sqlplus(startup_cmd)
    Puppet.notice('Oracle DB instance restarted.')
  end
end
