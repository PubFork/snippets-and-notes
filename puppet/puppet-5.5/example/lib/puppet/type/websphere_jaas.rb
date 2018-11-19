require 'pathname'

# TODO: validate on required params
Puppet::Type.newtype(:websphere_jaas) do
  @doc = <<-DOC
    @summary Java authentication something security. Proof of concept and still requires vetting. Retained as documentation for future custom types and providers for websphere.

    @example Java authentication something security.
      websphere_jaas { 'pega user':
        ensure           => present,
        cell             => 'DEVCell01',
        jaas_alias       => 'cool',
        jaas_user        => 'cool',
        jaas_password    => 'coolpass',
        profile_base     => '/IBM/WebSphere/AppServer',
        user             => 'svc_account',
        wsadmin_user     => 'wsuser',
        wsadmin_password => 'password',
      }
  DOC

  ensurable

  newparam(:profile) do
    desc <<-EOT
      Optional. The profile of the server to use for executing wsadmin commands.

      Example:
    EOT
  end

  newparam(:profile_base) do
    desc <<-EOT
      The base directory that profiles are stored. If no profiles, then the base directory with the bin directory.

      Example: /IBM/WebSphere/AppServer/profiles
      Example: /IBM/WebSphere/Appserver"
    EOT

    validate do |value|
      raise("Invalid profile_base #{value}") unless Pathname.new(value).absolute?
    end
  end

  # params and properties
  newparam(:cell) do
    desc 'The cell that this node should be a part of.'
  end

  newparam(:user) do
    desc 'Optional. The user to run "wsadmin" with.'
    newvalues(%r{^[-0-9A-Za-z._]+$})
    defaultto :root
  end

  newproperty(:jaas_alias) do
    desc 'The alias for jaas authentication.'
  end

  newparam(:jaas_user) do
    desc 'The username for jaas authentication.'
    newvalues(%r{^[-0-9A-Za-z._]+$})
  end

  newproperty(:jaas_pass) do
    desc 'The password for jaas authentication.'
  end

  newproperty(:jaas_desc) do
    desc 'The description for jaas authentication.'
    defaultto 'managed by Puppet'
  end

  newparam(:wsadmin_user) do
    desc 'The username for wsadmin authentication.'
    newvalues(%r{^[-0-9A-Za-z._]+$})
  end

  newparam(:wsadmin_pass) do
    desc 'The password for wsadmin authentication.'
  end

  # autorequires
  autorequire(:user) do
    self[:user]
  end

  autorequire(:user) do
    self[:wsadmin_user] unless self[:wsadmin_user].nil?
  end

  autorequire(:user) do
    self[:jaas_user]
  end

  autorequire(:file) do
    self[:profile_base]
  end

  autorequire(:file) do
    self[:profile_base] + '/' + self[:profile] unless self[:profile].nil?
  end
end
