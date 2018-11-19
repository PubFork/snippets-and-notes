Puppet::Type.newtype(:db_restart) do
  @doc = <<-'EOT'
    Manages Oracle DB restarts.  The `db_restart` type is typically
    used in situations where a resource performs a change, e.g.
    system setting altered, and a restart is required to recognize
    modification.  Only if the setting is modified should the
    reboot be triggered.

    Sample usage:

        db_config { 'sga_max_size':
          param_value => '5G',
          os_user     => 'oracle',
          oracle_home => '/oracle/product/12.2.0.1/dbhome',
        }
        db_restart { 'after':
          subscribe       => Db_config['sga_max_size'],
          shutdown_option => 'immediate',
          oracle_home     => '/oracle/product/12.2.0.1/dbhome',
        }

    A db_restart resource can also finish the run and then restart the Oracle DB. For
    example: if you have a few modified settings that all require
    restarts, but will not block each other during the run.

    Sample usage:

        db_config { 'sga_max_size':
          param_value => '5G',
          os_user     => 'oracle',
          oracle_home => '/oracle/product/12.2.0.1/dbhome',
        }
        db_restart { 'after':
          apply          => finished,
          startup_option => 'upgrade',
          oracle_home    => '/oracle/product/12.2.0.1/dbhome',
          subscribe      => Db_config['sga_max_size'],
        }
  EOT

  feature :refreshable, 'The provider can restart the service.',
          methods: [:restart]

  newparam(:name) do
    desc 'The name of the db_restart resource. Used for uniqueness.'
    isnamevar
  end

  newparam(:apply) do
    desc "When to apply the restart. If `during`, then the provider
      will apply the restart once puppet has finished applying depending
      resources (normal refresh behavior). If `finished`, it will continue
      applying resources and then perform a restart at the end of the
      run. The default is `during`."
    newvalues(:during, :finished)
    defaultto :during
  end

  newparam(:shutdown_option) do
    desc "Shutdown option to use. Default is `normal`.
          Example: immediate"

    newvalues(:normal, :immediate)
    defaultto :normal

    munge do |value|
      value.upcase
    end
  end

  newparam(:startup_option) do
    desc "Optional Startup option to use. Default is `none`.
          Example: upgrade"

    newvalues(:none, :upgrade)
    defaultto :none

    munge do |value|
      value == :none ? 'STARTUP' : "STARTUP #{value.upcase}"
    end
  end

  newparam(:os_user) do
    desc 'The OS user for Oracle. Default is `oracle`.'
    defaultto :oracle
  end

  newparam(:oracle_home) do
    desc 'The Oracle product home directory'
    newvalues(%r{^/[/\w.]+$})
  end

  autorequire(:user) do
    self[:os_user]
  end

  @restarting = false

  class << self
    attr_accessor :restarting
  end

  def refresh
    if self.class.restarting
      Puppet.debug('Restart already scheduled; skipping.')
    else
      self.class.restarting = true
      Puppet.notice('Scheduling Oracle DB restart.')
      provider.restart
    end
  end
end
