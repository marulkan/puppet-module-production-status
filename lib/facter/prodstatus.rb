Facter.add('production_state') do
  setcode do
    Facter::Core::Execution.exec('cat /etc/prodstatus/state')
  end
end
Facter.add('production_type') do
  setcode do
    Facter::Core::Execution.exec('cat /etc/prodstatus/type')
  end
end
