let(:facts) do
  os_facts.merge(
    processors: { models: ['AMD'] },
    memory: { system: { total: '12GB' } },
    networking: { fqdn: 'desktop.com', ip: '123.45.67.890', hostname: 'desktop' }
  )
end
