# class for interacting with service now cmdb
class ServiceNowCMDB
  require 'rest-client'
  require 'json'
  require 'date'

  # slightly helpful for efficiency and cleanliness
  NOW = Date.today

  def initialize(user, password, server, proxy = nil)
    require 'base64'

    # initialize base headers, api endpoint, and proxy
    @base_headers = { authorization: "Basic #{Base64.strict_encode64("#{user}:#{password}")}", accept: 'application/json' }
    @endpoint_prefix = "#{server}/api/now/cmdb/instance/"
    RestClient.proxy = proxy unless proxy.nil?
  end

  # read a cmdb instance and retrieve all names/sys_id, or specify a name to retrieve one node's info
  def main(classname, name = '', params = {})
    # verify, validate, and process input parameters
    headers = process_inputs(name, params)

    # retrieve and store appropriate response object from service now
    # if no server name specified, we just want to gather the names and sys_id of the class; else, gather the attribute entries of a server in a given class
    name.empty? ? class_cache(classname, headers) : server_cache(classname, name, headers)
  end

  private

  # verifies, validates, and processes inputs
  def process_inputs(name, params)
    # if both params were specified then something is wrong
    if params.key?(:sysparm_query) && params.key?(:sysparm_fields)
      raise 'sysparm_query parameter is only allowed with no name and sysparm_fields is only allowed with specified name; therefore, specifying both parameters is not allowed.'
    # no extra parameters specified
    elsif params.empty?
      @base_headers
    # an encoded query string used to filter the results
    elsif params.key?(:sysparm_query)
      raise 'sysparm_query requires no specified name' unless name.empty?
      raise 'sysparm_query must be an encoded query string' unless params[:sysparm_query].is_a?(String)
      @base_headers.merge(params: params)
    # a comma-separated list of fields to return in the response
    elsif params.key?(:sysparm_fields)
      raise 'sysparm_fields requires a specified name' if name.empty?
      raise 'sysparm_fields must be an array of strings' unless params[:sysparm_fields].is_a?(Array)
      @base_headers.merge(params: { sysparm_fields: params[:sysparm_fields].join(',') })
    # something went wrong with the specified params
    else
      raise "Unsupported parameter specified in #{params}."
    end
  end

  # caching logic for class entries of name and sys_id; returns array of hashes with :name and :sys_id keys
  def class_cache(classname, headers, expiry = 5)
    # grab the sysparm_query for cache file name, otherwise empty string
    sysparm_query = headers.dig(:params, :sysparm_query)
    # establish location of cache file
    cache = "/tmp/#{classname}_#{sysparm_query}cache.json"

    # if there is a relevant cache file under expiry days old, then use it
    body = if File.readable?(cache) && (NOW - File.mtime(cache).to_date).to_i < expiry
             # read response from cached file
             File.read(cache)
           else
             # query response of all names/sys_id in class
             query_body = cmdb_request(classname, headers)
             # cache the response in a file
             File.write(cache, query_body)
             query_body
           end

    # parse body and return array of hashes with :name and :sys_id keys
    JSON.parse(body, symbolize_names: true)[:result]
  end

  # caching logic for server entries of attributes; returns hash of attr keys and value values
  def server_cache(classname, name, headers, expiry = 5)
    # grab the sysparm_fields for cache file name, otherwise empty string
    sysparm_fields = headers.dig(:params, :sysparm_fields)
    # establish location of cache file
    cache = "/tmp/#{classname}_#{name}_#{sysparm_fields}cache.json"

    # if there is a relevant cache file under expiry days old, then use it
    body = if File.readable?(cache) && (NOW - File.mtime(cache).to_date).to_i < expiry
             # read response from cached file
             File.read(cache)
           else
             # we need to retrieve the sys_id of the associated name entry and use it in the request
             query_body = cmdb_request("#{classname}/#{name_to_sys_id(name, classname)}", headers)
             # cache the response in a file
             File.write(cache, query_body)
             query_body
           end

    # parse body and return hash of attr keys and value values
    JSON.parse(body, symbolize_names: true)[:result][:attributes]
  end

  # request all names and sys_ids for class and then return sys_id associated with name entry
  def name_to_sys_id(name, classname)
    # gather all of the names and sys_id of the class
    entries_array = class_cache(classname, @base_headers)
    # return array containing only the hash with the desired name and sys_id
    filtered_array = entries_array.select { |entry| entry[:name] == name }
    # was the name not in the entries?
    if filtered_array.empty?
      # try again with forced no cache
      entries_array = class_cache(classname, @base_headers, 0)
      filtered_array = entries_array.select { |entry| entry[:name] == name }
      # still no entries with the name found?
      if filtered_array.empty?
        # try again with less restrictive conditional using regexp
        filtered_array = entries_array.select { |entry| entry[:name] =~ Regexp.new(name) }
        # raise an error because we did everything that we could
        raise "#{name} not found among CMDB entries in class #{classname}." if filtered_array.empty?
      end
    end
    # check if multiple name entries were found, because that is bad
    raise "There were multiple matches for #{name} in the CMDB class #{classname}." if filtered_array.length > 1
    # return sys_id of desired name entry
    filtered_array[0][:sys_id]
  end

  # request and return response body from the service now cmdb
  def cmdb_request(endpoint_suffix, headers)
    RestClient::Request.execute(method: :get,
                                url: @endpoint_prefix + endpoint_suffix,
                                verify_ssl: false,
                                headers: headers).body
  rescue RestClient::ExceptionWithResponse => err
    # check if the response contains a useful message and display if so
    body = JSON.parse(err.response.body, symbolize_names: true)
    body.key?(:error) ? (raise body[:error][:message]) : (raise body)
  end
end
