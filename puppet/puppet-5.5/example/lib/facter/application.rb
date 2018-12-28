require 'facter'

# custom fact that determines the application of a server
Facter.add(:application) do
  setcode do
    # initially based upon operating system
    case Facter.value(:kernel)
    when 'windows'
      # on windows based upon return value of execution
      case Facter::Core::Execution.execute('powershell (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\ProductOptions\).producttype')
      when /NT/ then 'controller'
      else 'Generic'
      end
    when 'Linux'
      'Generic'
    else abort "#{Facter.value(:kernel)} is not supported."
    end
  end
end
