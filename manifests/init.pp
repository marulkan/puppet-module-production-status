# == Class: prodstatus
#
# This module manages the production status of a machine and sets banners
# acordingly.
#

class prodstatus (
  $ensure = 'present',
  $allowed_cost         = ['Customer1'],
  $allowed_states       = {
    pre_prod => ['Installing', 'PoC', 'Sandbox'],
    prod     => ['In Production'],
    decom    => ['Decomissioned'] },
  $allowed_server_types = ['Infrastructure'],
  $motd                 = 'USE_DEFAULTS',
  $cost                 = 'Customer1',
  $state                = 'Installing',
  $type                 = 'Infrastructure',
  $file_path            = '/etc/prodstatus', # Changing this will break the facts.
  $cost_extra           = undef,
  $fact_location        = '/etc/facter/facts.d', # Default in puppet, other modules handle this path.
) {
  if $ensure == 'present' {

  case $::osfamily {
    'Debian', 'Ubuntu': {
      $default_motd = false
    }
    'Suse', 'RedHat', 'Solaris': {
      $default_motd = true
    }
    default: {
      fail("prodstatus supports osfamilies Ubuntu, Debian, RedHat, Solaris and Suse. Detected osfamily is <${::osfamily}>.")
    }
  }

  if $motd == 'USE_DEFAULTS' {
    $motd_real = $default_motd
  } else {
    $motd_real = $motd
  }

  if !$motd_real {
    file { 'motd-ubuntu':
      ensure => file,
      path   => '/etc/update-motd.d/99-prodstatus',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    file_line { 'motd_bash':
      path  => '/etc/update-motd.d/99-prodstatus',
      match => '^#!/bin/bash',
      line  => '#!/bin/bash',
    }
  }

  # /etc/prodstatus should always be present
  file { 'prodstatus':
    ensure => directory,
    path   => $file_path,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # General stuff that will be applied in all cases
  # except when we don't have an valid state.
  # Merge the hash for some validation.
  $all_states = flatten(values($allowed_states))
  if member($all_states, $state) and $motd_real {
    file { 'production-state':
      ensure  => file,
      path    => "${file_path}/state",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $state,
      require => File['prodstatus'],
    }

    file_line { 'motd_state':
      path  => '/etc/motd',
      match => '^Production state:',
      line  => "Production state: ${state}",
    }
  }
  elsif member($all_states, $state) and !$motd_real {
    file { 'production-state':
      ensure  => file,
      path    => "${file_path}/state",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $state,
      require => File['prodstatus'],
    }

    file_line { 'motd_state':
      path  => '/etc/update-motd.d/99-prodstatus',
      match => "^echo \"Production state:\"",
      line  => "echo \"Production state: ${state}\"",
      require => File_line['motd_bash']
    }
  }
  else {
    notify { "${state} is not a valid state!": }
  }

  if member($allowed_server_types, $type) and $motd_real {
    file { 'production-type':
      ensure  => file,
      path    => "${file_path}/type",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $type,
      require => File['prodstatus'],
    }

    file_line { 'motd_type':
      path  => '/etc/motd',
      match => '^Production type:',
      line  => "Production type: ${type}",
    }
  }
  elsif member($allowed_server_types, $type) and !$motd_real {
    file { 'production-type':
      ensure  => file,
      path    => "${file_path}/type",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $type,
      require => File['prodstatus'],
    }

    file_line { 'motd_type':
      path  => '/etc/update-motd.d/99-prodstatus',
      match => "^echo \"Production type:\"",
      line  => "echo \"Production type: ${type}\"",
      require => File_line['motd_bash']
    }
  }
  else {
    notify { "${type} is not a valid type!": }
  }

  if member($allowed_cost, $cost) {
    file { 'production-cost':
      ensure  => file,
      path    => "${file_path}/cost",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $cost,
      require => File['prodstatus'],
    }
    if $cost_extra {
      file { 'second-cost-fact':
        ensure  => file,
        path    => "${fact_location}/${cost_extra}.txt",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${cost_extra}=${cost}",
      }
    }
  }
  else {
    notify { "${cost} is not a valid cost!": }
  }
 }
 elsif $ensure == 'absent' {
   file { 'production-state':
     ensure => absent,
     path   => "${file_path}/state",
   }
   file { 'production-type':
     ensure => absent,
     path   => "${file_path}/type",
   }
   file { 'production-cost':
     ensure => absent,
     path   => "${file_path}/cost",
   }
   file_line { 'motd_type':
     ensure            => absent,
     path              => '/etc/motd',
     match             => '^Production type:',
     match_for_absence => true,
     multiple          => true,
  }
   file { 'second-cost-fact':
     ensure => absent,
     path   => "${fact_location}/${cost_extra}.txt",
   }
 }
}
