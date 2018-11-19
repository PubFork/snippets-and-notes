# TODO: parameterize script
require 'erb'
require 'optparse'

# parse cli flags and args
opt_parser = OptionParser.new do |opts|
  # usage
  opts.banner = 'usage: ruby converter [options] script'

  # arg parsing
  opts.on('-n', '--name task_name', String, 'Name of task.') { |arg| @name = arg }
end

opt_parser.parse!(ARGV)

# read in script content
raise 'Specify only one script.' if ARGV.length > 1
@script = File.read(ARGV[0])

# output wrapper if not natively supported
File.write("#{@name}.rb", ERB.new(File.read('task.erb')).result(binding)) unless ['.rb', '.ps1', '.py', '.sh'].include?(ARGV[0])
# output metadata
File.write("#{@name}.json", ERB.new(File.read('metadata.erb')).result(binding))