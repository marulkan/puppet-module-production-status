Facter.add('production_state') do
  fcv = Facter.value(:facterversion).split('.')
  if fcv[0] == '1'
    setcode do
      if File.exist? '/etc/prodstatus/state'
        Facter::Util::Resolution.exec('cat /etc/prodstatus/state')
      else
        'NA'
      end
    end
  else
    setcode do
      if File.exist? '/etc/prodstatus/state'
        Facter::Core::Execution.exec('cat /etc/prodstatus/state')
      else
        'NA'
      end
    end
  end
end
Facter.add('production_type') do
  fcv = Facter.value(:facterversion).split('.')
  if fcv[0] == '1'
    setcode do
      if File.exist? '/etc/prodstatus/type'
        Facter::Util::Resolution.exec('cat /etc/prodstatus/type')
      else
        'NA'
      end
    end
  else
    setcode do
      if File.exist? '/etc/prodstatus/type'
        Facter::Core::Execution.exec('cat /etc/prodstatus/type')
      else
        'NA'
      end
    end
  end
end
