require 'facter'
require 'yaml'

# facter plugin class to instantiate metadata
class FacterPlugin
  def initialize
    # determine where server info file is located
    server_file = case Facter.value(:osfamily)
                  when /windows/i then 'C:\app\server.yaml'
                  when /redhat/i then '/etc/server.yaml'
                  when /aix/i then '/opt/server.yaml'
                  when /darwin/ then '/home/server.yaml'
                  else raise 'Operating System not recognized!'
                  end

    # load in server info
    begin
      @server_info = YAML.load_file(server_file)
    rescue SystemCallError
      raise "Server information file not found at #{server_file}!"
    rescue StandardError
      raise "The server information file at #{server_file} is not formatted correctly!"
    end

    # check that file is not empty
    raise "Server info file at #{server_file} is empty!" if @server_info.nil?
  end

  # determine server owner
  def key
    raise 'Key not found in server information file!' unless @server_info.key?(:key)
    @server_info[:key]
  end
end
