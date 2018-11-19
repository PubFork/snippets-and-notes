# returns a jvm instance name corresponding to the input port
Puppet::Functions.create_function(:'jvm_port_to_name') do
  # returns a jvm instance name corresponding to the input port
  # @param port The JVM instance port.
  # @return [String] Returns the JVM instance name.
  # @example Returning a name based on a port.
  #   jvm_port_to_name('9990') => 'DEV2_01'
  dispatch :convert do
    param 'String', :port
    return_type 'String'
  end

  def convert(port)
    closure_scope['facts']['jvms'].each { |instance, attrs| return instance if port == attrs['port'] }
    raise "No JVM instance was found for #{port}!"
  end
end
