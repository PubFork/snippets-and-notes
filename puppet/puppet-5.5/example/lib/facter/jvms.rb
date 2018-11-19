# gathers info about jvms on a server
Facter.add('jvms') do
  setcode do
    # ensure config file exists before proceeding
    if File.file?('/jboss.cfg')
      # init jvms hash
      jvms = {}
      # open config file for info parsing
      File.read('/jboss.cfg').each_line do |line|
        # skip if useless line
        next if line =~ %r{^#|^\n}
        # parse line of info
        jvm_info = line.split(%r{\s+})
        # grab instance name for top level hash key and init nested hash
        instance_name = jvm_info[0].to_sym
        jvms[instance_name] = {}
        # assign key value pairs for instance info
        jvms[instance_name][:min_heap] = jvm_info[1]
        jvms[instance_name][:max_heap] = jvm_info[2]
        jvms[instance_name][:port] = (jvm_info[3].to_i + 9990).to_s
        jvms[instance_name][:dns_alias] = jvm_info[4]
      end
      # return jvm info
      jvms
    else
      # return empty hash if not config file present
      {}
    end
  end
end
