$password = Sensitive('password')

if $facts['osfamily'] == 'windows' {
  $dir = $facts['os']['architecture'] ? {
    'x86'   => 'C:\Program Files (x86)\dir',
    'x64'   => 'C:\Program Files\dir',
    default => "C:\\Program Files (${facs['os']['architecture']})\\dir",
  }
}

registry::value { 'HKLM\SYSTEM\CurrentControlSet\Services\ServiceName\DelayedAutostart':
  ensure  => present,
  type    => dword,
  data    => '1',
  require => Service['ServiceName'],
}

$version_array = split($version, '\.')

$maj_version = $version[0, 2]

$pkg_version = regsubst($version, '-', '.')

transition { 'stop the service':
  resource   => Service['the service'],
  attributes => { ensure => stopped },
  prior_to   => Package['the package'],
}
service { 'the service':
  ensure    => running,
  subscribe => [Package['the package'], File['the config']],
  require   => Exec['postinstall fixes'],
}

case $facts['os']['name'] {
  'RedHat', 'Solaris': {
    $password = $environment ? {
      /test|dev/   => $dev_password,
      'qa'         => $qa_password,
      'production' => $prod_password,
      default      => fail("Unknown directory environment detected. No root password available for environment ${environment}.")
    }
  }
  default: { fail("Unsupported operating system ${facts['os']['name']} detected.") }
}

user { 'root':
  ensure   => present,
  password => Sensitive($password),
  expiry   => absent,
}

case $facts['os']['name'] {
  'RedHat', 'Centos': {
    $forwarders = $facts['os']['release']['major'] ? {
      '7'     => { ensure => absent },
      default => {},
    }

    file {
      default:
        ensure => file,
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
        notify => Service['rsyslog'],
      ;
      '/etc/rsyslog.conf': source => "puppet:///modules/${module_name}/rsyslog-rhel${facts['os']['release']['major']}.conf"
      ;
      '/etc/rsyslog.d/unused.conf': source => 'puppet:///modules/syslog/unused.conf'
      ;
      '/etc/rsyslog.d/audit.conf': source => 'puppet:///modules/syslog/audit.conf'
      ;
      '/etc/rsyslog.d/forwarders.conf':
        content => template('syslog/forwarders.conf-client.erb'),
        *       => $forwarders,
      ;
      '/etc/logrotate.d/syslog': source => 'puppet:///modules/syslog/logrotate-syslog'
      ;
    }
  }
}

user { 'user': ensure => present }

if $facts['os']['name'] == 'AIX' {
  $aix_password = "'user:${password}'"

  exec { 'modify systems user password':
    command   => "/usr/bin/echo ${aix_password} | /usr/bin/chpasswd -ec ssha512",
    unless    => "/usr/bin/grep '${password}' /etc/security/passwd",
    logoutput => false,
  }
}
elsif $facts['os']['name'] =~ /RedHat|Windows/ {
  User['user'] { password => Sensitive($password) }
}

epp('example/bashrc.epp', { 'jvms' => ['jvm1', 'jvm2'] }) # string rvalue

include "profile::${downcase($facts['kernel'])}::base"

# append
File['/etc/passwd'] {
  owner => 'root',
  mode  => '0640',
}

# amend
File <| tag == 'base::linux' |> {
  owner => 'root',
  mode  => '0640',
  foo   +> ['bar', 'baz'], # appending to attributes that accept arrays
}

# jboss versioning always semantic
$jboss_version = $installation_file.match(/(\d\.\d\.\d)/)[1]

if versioncmp($jboss_version, '7') >= 0 {
  include elytron
}
else {
  include password_vault
}
