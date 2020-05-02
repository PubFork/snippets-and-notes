#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'open3'

# user inputs
settings = {}

opt_parser = OptionParser.new do |opts|
  opts.banner = 'usage: env_setup [options]'

  opts.on('-t', '--token 123456', String, 'MFA token') { |arg| settings[:token] = arg }
  opts.on('-a', '--account account', String, 'Account to retrieve credentials for') { |arg| settings[:account] = arg.to_sym }
  opts.on('-u', '--user username', String, 'MFA username') { |arg| settings[:user] = arg }
end

opt_parser.parse!(ARGV)

# initialize consts
ACCOUNTS = {
  one:   '123456789012',
  two:   '234567890123',
  three: '345678901234'
}

ENV.delete('AWS_ACCESS_KEY_ID')
ENV.delete('AWS_SECRET_ACCESS_KEY')
ENV.delete('AWS_SESSION_TOKEN')
ENV['AWS_PROFILE'] = 'root'

# authenticate cli with mfa
stdout, _ = Open3.capture2("aws sts get-session-token --serial-number arn:aws:iam::#{ACCOUNTS[:root]}:mfa/#{settings[:user]} --token-code #{settings[:token]}")

# parse return and grab creds
creds = JSON.parse(stdout)['Credentials']

# export mfa'ed creds
ENV['AWS_ACCESS_KEY_ID'] = creds['AccessKeyId']
ENV['AWS_SECRET_ACCESS_KEY'] = creds['SecretAccessKey']
ENV['AWS_SESSION_TOKEN'] = creds['SessionToken']

# assume role in other desired account
stdout, _ = Open3.capture2("aws sts assume-role --role-arn arn:aws:iam::#{ACCOUNTS[settings[:account]]}:role/CrossAccountRole --role-session-name cli")

# parse return and grab creds
creds = JSON.parse(stdout)['Credentials']

# output command to setup env
puts "Execute the following command to interact with #{settings[:account]}:"
puts "export AWS_PROFILE=#{settings[:account]} && AWS_ACCESS_KEY_ID=#{creds['AccessKeyId']} && export AWS_SECRET_ACCESS_KEY=#{creds['SecretAccessKey']} && export AWS_SESSION_TOKEN=#{creds['SessionToken']}"
