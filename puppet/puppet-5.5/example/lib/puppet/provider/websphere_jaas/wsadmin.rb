begin
  require_relative '../../../../puppetlabs-websphere/lib/puppet/provider/websphere_helper'
rescue LoadError
  require_relative '../../../../websphere_application_server/lib/puppet/provider/websphere_helper'
end

Puppet::Type.type(:websphere_jaas).provide(:wsadmin, parent: Puppet::Provider::Websphere_Helper) do
  desc 'wsadmin provider for `websphere_jaas`'

  # base methods for provider ensurable
  def create
    # create jaas with specified attributes
    jaas_attrs = "[['alias', #{resource[:jaas_alias]}], ['userId', #{resource[:jaas_user]}], ['password', #{resource[:jaas_pass]}], ['description', #{resource[:jaas_desc]}]]"
    cmd = "\"AdminConfig.create('JAASAuthData', #{security_cell}, #{jaas_attrs})\""

    run_cmd(cmd)
  end

  def exists?
    find_jaas
    # if a jaas userid was found, then the jaas exists; otherwise, empty was returned and jaas does not exist
    @jaas.empty? ? false : true
  end

  def destroy
    # assign jaas if not found yet
    find_jaas
    # remove jaas; jaas cannot be empty unless there is a bug in .exists?
    run_cmd("\"AdminConfig.remove(#{@jaas})\"")
  end

  def flush
    super
    wsadmin(command: '"AdminConfig.save()"', user: resource[:user])
  end

  # attribute getters and setters
  def jaas_alias
    find_jaas
    show_attr(@jaas, 'alias')
  end

  def jaas_alias=(*)
    find_jaas
    run_cmd("\"AdminConfig.modify(#{@jaas}, [['alias', '#{resource[:jaas_alias]}']])\"")
  end

  def jaas_pass
    find_jaas
    show_attr(@jaas, 'password')
  end

  def jaas_pass=(*)
    find_jaas
    run_cmd("\"AdminConfig.modify(#{@jaas}, [['password', '#{resource[:jaas_pass]}']])\"")
  end

  def jaas_desc
    find_jaas
    show_attr(@jaas, 'description')
  end

  def jaas_desc=(*)
    find_jaas
    run_cmd("\"AdminConfig.modify(#{@jaas}, [['description', #{resource[:jaas_desc]}]])\"")
  end

  # private helper methods for provider
  private

  # retrieve security cell value
  def security_cell
    wsadmin(command: "\"AdminConfig.getid('/Cell:#{resource[:cell]}/Security:/')\"", user: resource[:user])
  end

  # list jaasauthdata from config
  def config_list
    wsadmin(command: "\"AdminConfig.list('JAASAuthData', #{security_cell})\"", user: resource[:user])
  end

  # retrieve value for a jaas attribute
  def show_attr(jaas, attr)
    wsadmin(command: "\"AdminConfig.showAttribute(#{jaas}, #{attr})\"", user: resource[:user])
  end

  # retrieve jaas that corresponds to specified user id
  def find_jaas
    # skip this if we already attempted to find jaas
    return unless @jaas.nil?

    # iterate through config list to find user
    config_list.each_line do |jaas|
      # skip non-matching users
      next unless show_attr(jaas, 'userId') == resource[:jaas_user]
      # stop iteration and return jaas when user found
      return @jaas = jaas
    end

    # jaas not found; return empty string
    @jaas = ''
  end

  # leverage mixin base provider and provide debug output
  def run_cmd(cmd)
    Puppet.debug "Running #{cmd}"
    result = wsadmin(command: cmd, user: resource[:user])
    Puppet.debug result
  end
end
