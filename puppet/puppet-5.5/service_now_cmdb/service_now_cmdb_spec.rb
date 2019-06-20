require_relative 'service_now_cmdb'

describe ServiceNowCMDB do
  let(:svcnow) { ServiceNowCMDB.new('user', 'pass', 'servicenow.com', 'proxy.com') }

  context '.new' do
    it 'initializes successfully with no proxy' do
      no_proxy = ServiceNowCMDB.new('user', 'pass', 'servicenow.com')
      expect(no_proxy.instance_variable_get(:@base_headers)).to eq({ authorization: "Basic #{Base64.strict_encode64('user:pass')}", accept: 'application/json' })
      expect(no_proxy.instance_variable_get(:@endpoint_prefix)).to eq('servicenow.com/api/now/cmdb/instance/')
    end
    it 'initialize successfully with a proxy' do
      expect { svcnow }.to_not raise_error
    end
  end

  context '.process_inputs' do
    it 'does not allow two conflicting params' do
      expect { svcnow.send(:process_input, 'class', nil, sysparm_query: 'query', sysparm_fields: %w[foo bar]) }.to raise_error(RuntimeError, 'sysparm_query parameter is only allowed with no sys_id and sysparm_fields is only allowed with specified sys_id; therefore, specifying both parameters is not allowed.')
    end
    it 'does not allow a sysparm_query with a sys_id' do
      expect { svcnow.send(:process_input, 'class', 'abcd', sysparm_query: 'foo') }.to raise_error(RuntimeError, 'sysparm_query requires no specified sys_id')
    end
    it 'does not allow a sysparm_query that is not a string' do
      expect { svcnow.send(:process_input, 'class', nil, sysparm_query: %w[foo bar]) }.to raise_error(RuntimeError, 'sysparm_query must be an encoded query string')
    end
    it 'does not allow a sysparm_fields with no sys_id' do
      expect { svcnow.send(:process_input, 'class', nil, sysparm_fields: %w[foo bar]) }.to raise_error(RuntimeError, 'sysparm_fields requires a specified sys_id')
    end
    it 'does not allow a sysparm_fields that is not an array of strings' do
      expect { svcnow.send(:process_input, 'class', 'abcd', sysparm_fields: 'foo') }.to raise_error(RuntimeError, 'sysparm_fields must be an array of strings')
    end
    it 'does not allow an illegal parameter' do
      expect { svcnow.send(:process_input, 'class', nil, what: 'is_this') }.to raise_error(RuntimeError, /Unsupported parameter specified in.*what/)
    end
    it 'returns headers correctly for no params' do
      expect(svcnow.send(:process_input, 'class', 'name')).to eq(svcnow.instance_variable_get(:@base_headers))
    end
    it 'returns headers correctly for a sysparm_query' do
      expect(svcnow.send(:process_input, 'class', 'name', sysparm_query: 'foo')).to eq(svcnow.instance_variable_get(:@base_headers).merge(params: { sysparm_query: 'foo' }))
    end
    it 'returns headers correctly for a sysparm_fields' do
      expect(svcnow.send(:process_input, 'class', 'name', sysparm_fields: %w[foo bar])).to eq(svcnow.instance_variable_get(:@base_headers).merge(params: { sysparm_fields: 'foo,bar' }))
    end
  end

  context '.class_cache' do
  end

  context '.server_cache' do
  end

  context '.name_to_sys_id' do
  end

  context '.cmdb_request' do
  end
end
