# simple class to publish facts for collection by filebeat to logstash
class facter_filebeat {
  package { 'elasticsearch':
    ensure   => installed,
    provider => 'gem',
  }

  file { '/etc/filebeat/inputs.d/facter.yml':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/facter.yml",
    notify => Service['filebeat'],
    #require => Package['filebeat'],
  }

  service { 'filebeat': ensure => running }

  exec { 'create interim facts json file': command => '/opt/puppetlabs/bin/facter -p -j >/opt/puppetlabs/facter/staging.json' }

  exec { 'create properly formatted facts json file':
    command => "/opt/puppetlabs/puppet/bin/ruby -e \"require 'json'; parsed = JSON.parse(File.read('/opt/puppetlabs/facter/staging.json')); File.write('/opt/puppetlabs/facter/facter.json', JSON.generate(parsed))\"",
    require => Exec['create interim facts json file'],
  }

  exec { 'publish directly to elastic':
    command => "/opt/puppetlabs/puppet/bin/ruby -e \"require 'elasticsearch'; require 'json'; parsed = JSON.parse(File.read('/opt/puppetlabs/facter/staging.json')); client = Elasticsearch::Client.new(log: true); client.index(index: 'facter', type: 'facts', id: 1, body: parsed)\"",
    require => [Exec['create interim facts json file'], Package['elasticsearch']],
  }
}
