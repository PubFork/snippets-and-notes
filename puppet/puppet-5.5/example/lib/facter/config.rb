require 'facter'

# custom fact that determines the config of a server
Facter.add(:config) do
  setcode do
    # init var for single lookup
    config_file = case Facter.value(:kernel)
                   when 'windows'
                     'C:\programdata\config.txt'
                   when 'Linux'
                     '/home/admin/config.txt'
                   else abort 'Unsupported operating system.'
                   end

    # verify existence of config kv store
    if File.file?(config_file)
      # attempt to load in config name
      begin
        config = File.read(config_file).lines.first.strip
        # check validity of config name
        abort "#{config} is not a valid config." unless config =~ /^([a-zA-Z0-9,()-]|\s)+$/
        # return first line of config with removed whitespace/newlines
        config
      rescue LoadError
        abort "#{config_file} has been corrupted."
      end
    else
      # warn and return no fact if the config file was not found on the server
      Facter.warn("#{config_file} does not exist on #{Facter.value(:networking)['fqdn']}.")
      nil
    end
  end
end
