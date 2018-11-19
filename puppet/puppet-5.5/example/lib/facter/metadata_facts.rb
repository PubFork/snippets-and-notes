# metadata facts for servers
require_relative 'facter_plugin'

metadata_facts = FacterPlugin.new

Facter.add(:key) { setcode { metadata_facts.key } }
