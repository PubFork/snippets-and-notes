require 'facter'

# custom fact that determines the subscription_status of a server
Facter.add(:subscription_status) do
  setcode do
    # check the operating system
    case Facter.value(:kernel)
    when 'windows'
      'Windows Server'
    when 'Linux'
      # check the existence of 'subscription-manager' in the shell path
      if Facter::Core::Execution.which('subscription-manager')
        # TODO: optimize
        if Facter.value(:os)['release']['major'] == '6'
          # shell out the command the subscription-manager status
          stdout = Facter::Core::Execution.execute('subscription-manager list')
          # format the stdout to only retain the actual status
          stdout.partition('Status:').last.lines.first.strip
        elsif Facter.value(:os)['release']['major'] == '7'
          # shell out the command  the subscription-manager status
          stdout = Facter::Core::Execution.execute('subscription-manager status')
          # format the stdout to only retain the actual status
          stdout.partition('Status:').last.strip
        end
      else
        abort "'subscription-manager' is not in the shell path on #{Facter.value(:networking)['fqdn']}."
      end
    else abort "Unsupported operating system #{Facter.value(:os)['family']} #{Facter.value(:os)['release']['full']}."
    end
  end
end
