#!/opt/puppetlabs/puppet/bin/ruby
# @summary
#   Patches JBOSS on a server.
#
# @example
#   puppet task run moodys_jboss::patch_jboss os_user=s_jb_dv patch_source=http://ftc-lbpupart201.ad.moodys.net/artifacts/jboss/jboss-eap-7.1.6-patch.zip --nodes ftc-lbsndbox043.ad.moodys.net
#
# @param os_user
#   OS user to run jboss-cli as.
#
# @param patch_source
#   HTTP URI location of the patch file to download. This is preferably from the Moodys artifact server repository.
#
# @optional_param cli_path
#   Directory location of the jboss-cli executable. Default value '/opt/jboss/bin'.
#
require 'open3'
require 'json'
require 'puppet'
require 'open-uri'
#TODO: figure out better way of loading user env (first arg to open3 is hash of env => value)

# initialize params
params = JSON.parse(STDIN.read, symbolize_names: true)
params[:cli_path] = '/opt/jboss/bin' if params[:cli_path].nil?

# switch process to os_user
begin
  Process.uid = Process.euid = Process::UID.from_name(params[:os_user])
rescue ArgumentError
  raise Puppet::Error, _("User #{params[:os_user]} does not exist.")
end

# check bashrc is readable
bashrc = Dir.home(params[:os_user]) + '/.bashrc'
raise Puppet::Error, _("#{params[:os_user]}'s #{bashrc} is not readable.") unless File.readable?(bashrc)

# download the patch file
case io = open(params[:patch_source])
when StringIO then File.write('/tmp/jboss-patch.zip', io)
when Tempfile
  io.close
  File.rename(io.path, '/tmp/jboss-patch.zip')
end

# ensure the jboss-cli exists and is executable by the user
raise Puppet::Error, _("#{params[:cli_path]}/jboss-cli.sh is not executable.") unless File.executable?("#{params[:cli_path]}/jboss-cli.sh")

# apply the patch
stdout, stderr, status = Open3.capture3(". #{bashrc} && #{params[:cli_path]}/jboss-cli.sh 'patch apply /tmp/jboss-patch.zip'")

# check on success of patching
unless status.exitstatus.zero?
  puts 'JBOSS was not successfully patched.'
  message = stderr.empty? ? stdout : stderr
  raise Puppet::Error, _(message)
end

# remove the patch file
File.delete('/tmp/jboss-patch.zip')

# restart the jboss eap server
stdout, stderr, status = Open3.capture3(". #{bashrc} && #{params[:cli_path]}/jboss-cli.sh 'shutdown --restart=true'")

# check on success of jboss restart
case status.exitstatus
when 0
  puts 'JBOSS successfully patched and restarted.'
  exit 0
else
  puts 'JBOSS was not successfully restarted.'
  message = stderr.empty? ? stdout : stderr
  exit raise Puppet::Errror, _(stdout)
end
