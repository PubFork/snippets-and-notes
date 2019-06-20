# returns a hash of server attributes for a service now cmdb name entry
Puppet::Functions.create_function(:cmdb_attributes) do
  # returns a hash of server attributes or class sys_id for a service now cmdb name entry
  # @param [String] classname The classname in the Service Now CMDB to query.
  # @optional_param [String] server The name of the server in the Service Now classname to query.
  # @optional_param [Hash] params The params (sysparm_query or sysparm_fields) to include in the request.
  # @return [Variant[Array[Hash], Hash]] Either returns an array of hashes of server names and sys id OR a hash of server attributes. Note that Ruby/REST/JSON recasts Booleans, Integers, etc. to Strings in the return keys and values.
  # @example Look up servers and sys id in the cmdb_ci_linux_server class.
  #   cmdb_attributes('cmdb_ci_linux_server') => [{ 'sys_id' => '0001c0f3dbfb278c02fb7e88f49619ad', 'name' => 'linux.com' }, { 'sys_id' => '03920aa2dbc51b00c21be1d3ca96190d', 'name' => 'linux2.com' }]
  # @example Look up attributes of db.com server in cmdb_ci_db_instance classname.
  #   cmdb_attributes('cmdb_ci_db_instance', 'db.com') => { 'first_discovered' => '2017-03-02 06:09:30', 'u_id' => '', 'u_scope' => 'false' }
  # @example Look up FQDN attribute of server.com server in cmdb_ci_server classname.
  #   cmdb_attributes('cmdb_ci_server', 'server.com', { sysparm_fields => ['fqdn'] }) => { 'fqdn' => 'server.com' }
  dispatch :attributes do
    param 'String', :classname
    optional_param 'String', :server
    optional_param 'Hash', :params
    return_type 'Variant[Array[Hash], Hash]' # leave hash key, value, min, and max unspecified to avoid big computational expense for little typecheck gain
  end

  def attributes(classname, server = '', params = {})
    require_relative 'service_now_cmdb'

    # load in settings from yaml config if possible
    settings = if File.readable?('/etc/puppetlabs/puppet/svc_now.yaml')
                 require 'yaml'

                 YAML.safe_load(File.read('/etc/puppetlabs/puppet/svc_now.yaml'), [Symbol])
               else
                 { user: 'user', pass: 'pass', server: 'https://www.service-now.com', proxy: 'http://proxy.net:80' }
               end

    # intialize cmdb object and then leverage for cmdb retrieval
    cmdb = ServiceNowCMDB.new(settings[:user], settings[:pass], settings[:server], settings[:proxy])
    cmdb.main(classname, server, params.map { |k, v| [k.to_sym, v] }.to_h)
  end
end
