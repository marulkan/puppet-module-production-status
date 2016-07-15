Facter.add('production_state') do
  fcv = :facterversion.split('.')
  if fcv[0] == '1'
    setcode do
      Facter::Util::Resolution.exec('cat /etc/prodstatus/state')
    end
  else
    setcode do
      Facter::Core::Execution.exec('cat /etc/prodstatus/state')
    end
  end
end
Facter.add('production_type') do
  fcv = :facterversion.split('.')
  if fcv[0] == '1'
    setcode do
      Facter::Util::Resolution.exec('cat /etc/prodstatus/type')
    end
  else
    setcode do
      Facter::Core::Execution.exec('cat /etc/prodstatus/type')
    end
  end
end
