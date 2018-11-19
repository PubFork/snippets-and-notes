#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'puppet'
require 'facter'

# initialize params
params = JSON.parse(STDIN.read)

# check for connection to master
begin
  if Facter.value(:kernel) == 'windows'
    # TODO
  else
    _, stderr, status = Open3.capture3("sudo curl -k https://#{params['puppet_master']}:8140")
    exit raise Puppet::Error, _(stderr) if status.exitstatus > 0
  end
end

# initialize puppet aio install command based upon operating system
upgrade_cmd = case Facter.value(:kernel)
              when 'windows' then "[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('https://#{params['puppet_master']}:8140/packages/current/install.ps1', 'install.ps1'); .\\install.ps1"
              else "sudo curl -k https://#{params['puppet_master']}:8140/packages/current/install.bash | sudo bash"
              end

# TODO: add '-s' for optional args if they exist (but all keys will be nil if optional and undef)
upgrade_cmd << ' -s' if params.keys.length > 1

# csr related options
upgrade_cmd << " custom_attributes:challengePassword=#{params['challenge_password']}" unless params['challenge_password'].nil?
upgrade_cmd << " extension_requests:pp_role=#{params['extension_requests']}" unless params['extension_requests'].nil?

# optional agent parameter flags and arguments
upgrade_cmd << " agent:certname=#{params['certname']} " unless params['certname'].nil?
upgrade_cmd << " agent:server=#{params['server']}" unless params['server'].nil?
upgrade_cmd << " agent:environment=#{params['environment']}" unless params['environment'].nil?
upgrade_cmd << ' agent:noop=true' if !params['noop'].nil? && params['noop']
upgrade_cmd << " agent:runinterval=#{params['runinterval']}" unless params['runinterval'].nil?

# run upgrade command
stdout, stderr, status = Open3.capture3(upgrade_cmd)

# provide information on status and output
case status.exitstatus
when 0
  puts 'Puppet agent successfully upgraded. Info as follows:'
  puts stdout
  exit 0
else
  puts "Puppet agent not successfully upgraded with status #{status}! Info as follows:"
  exit raise Puppet::Error, _(stderr)
end
