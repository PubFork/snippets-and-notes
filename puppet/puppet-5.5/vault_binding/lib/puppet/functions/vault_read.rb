# TODO: redirect vault errors to puppet errors; cache vault connection; error checking; docs/tests/enhance; https://www.rubydoc.info/gems/vault/0.12.0/Vault/Defaults; input checking
# Reads a secret from Vault.
Puppet::Functions.create_function(:vault_read) do
  # Reads a secret from Vault.
  # @param [String] secret The secret key to retrieve and read.
  # @param [String] field The field to read a value from the secret key.
  # @optional_param [String] yaml_config Optional yaml config file for Vault connection.
  # @return Variant[String, Numeric, Boolean, Array, Hash] Returns secret value.
  # @example Retrieve a secret.
  #   vault_read('secret/bacon', delicious) => true
  dispatch :read do
    param 'String', :secret
    param 'String', :field
    optional_param 'String', :yaml_config
    return_type 'Variant[String, Numeric, Boolean, Array, Hash]'
  end

  require 'puppet/util'

  def read(secret, field, yaml_config = '/etc/puppetlabs/puppet/vault.yaml')
    require 'vault'
    require 'yaml'

    # read in yaml config
    config_hash = YAML.safe_load(File.read(yaml_config), [Symbol])

    Vault.configure do |config|
      # The address of the Vault server, also read as ENV["VAULT_ADDR"]
      config.address = config_hash[:address] unless config_hash[:address].nil?
      # The token to authenticate with Vault, also read as ENV["VAULT_TOKEN"]
      # user provided token
      if !config_hash[:token].nil?
        config.token = config_hash[:token]

        # request new token with approle identities
        unless config_hash[:approle].nil?
          secret = Vault.auth.approle(Vault.approle.role_id(config_hash[:approle]), Vault.approle.create_secret_id(config_hash[:approle]).data[:secret_id])
          config.token = secret.auth.client_token
        end
      # user requests to generate a token specifically for this request
      elsif !config_hash[:generate_token].nil? && config_hash[:generate_token]
        # Request new access token as wrapped response where the TTL of the temporary token is 120s
        wrapped = Vault.auth_token.create(wrap_ttl: '120s')
        # Unwrap wrapped response for final token using the initial temporary token.
        config.token = Vault.logical.unwrap_token(wrapped)
      end

      # Proxy connection information, also read as ENV["VAULT_PROXY_(thing)"]
      config.proxy_address = config_hash[:proxy_address] unless config_hash[:proxy_address].nil?
      config.proxy_port = config_hash[:proxy_port] unless config_hash[:proxy_port].nil?
      config.proxy_username = config_hash[:proxy_username] unless config_hash[:proxy_username].nil?
      config.proxy_password = config_hash[:proxy_password] unless config_hash[:proxy_password].nil?
      # Custom SSL PEM, also read as ENV["VAULT_SSL_CERT"]
      if !config_hash[:ssl_pem_file].nil?
        config.ssl_pem_file = config_hash[:ssl_pem_file]
      # As an alternative to a pem file, you can provide the raw PEM string, also read in the following order of preference:
      # ENV["VAULT_SSL_PEM_CONTENTS_BASE64"] then ENV["VAULT_SSL_PEM_CONTENTS"]
      elsif !config_hash[:ssl_pem_contents].nil?
        config.ssl_pem_contents = config_hash[:ssl_pem_contents]
      # double alternatively, you can utilize a ca cert instead of a pem
      elsif !config_hash[:ssl_ca_cert].nil?
        config.ssl_ca_cert = config_hash[:ssl_ca_cert]
      end
      # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
      config.ssl_verify = config_hash[:ssl_verify] unless config_hash[:ssl_verify].nil?
      # Timeout the connection after a certain amount of time (seconds), also read
      # as ENV["VAULT_TIMEOUT"]
      config.timeout = config_hash[:timeout] unless config_hash[:timeout].nil?
      # It is also possible to have finer-grained controls over the timeouts, these
      # may also be read as environment variables
      config.ssl_timeout = config_hash[:ssl_timeout] unless config_hash[:ssl_timeout].nil?
      config.open_timeout = config_hash[:open_timeout] unless config_hash[:open_timeout].nil?
      config.read_timeout = config_hash[:read_timeout] unless config_hash[:read_timeout].nil?
    end

    # check if Vault is sealed
    raise(Puppet::Error, 'Vault is currently sealed.') if Vault.sys.seal_status.sealed?

    # connect to Vault
    Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError, Vault::HTTPClientError, Vault::HTTPServerError, attempts: 2, base: 0.05, max_wait: 2.0) do |attempt, except|
      # warn if exception raised and retry
      warn "Received exception #{except} from Vault on attempt number #{attempt}." unless except.nil?

      # read secret if successful
      secret = Vault.logical.read(secret)

      # notify if the secret does not exist
      raise(Puppet::Error, "No secret found at #{secret}.") if secret.nil?
      # is this kv v2? parse it appropriately; otherwise parse for kv v1
      secret.data.key?(:data) ? secret.data[:data][field.to_sym] : secret.data[field.to_sym]
    end
  end
end
