Facter.add(:environment) do
  setcode do
    case Facter.value(:hostname).downcase
    when /^c-dev-/, /^n-dev-/ then 'dev'
    when /^lc-dev/ then 'test'
    when /^c-uat/, /^n-uat/ then 'uat'
    when /^c-prod/, /^n-prod/ then 'prod'
    else 'unknown'
    end
  end
end

# custom fact to determine the environment of a server
Facter.add(:environment) do
  setcode do
    if Facter.value(:networking)['ip'].to_s =~ /^172\.21\.98\.([3-9][0-9]|100)$/
      'dev'
    elsif Facter.value(:hostname) =~ /^[vV][mM]/
      'dev'
    else
      'production'
    end
  end
end
