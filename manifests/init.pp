# == Class: prodstatus
#
# This module manages the production status of a machine and sets banners
# acordingly.
#

class prodstatus (
  $ensure = 'present',
  $allowed_states       = {
    pre_prod => ['Installing', 'PoC', 'Sandbox'],
    prod     => ['In Production'],
    decom    => ['Decomissioned'] },
  $allowed_server_types = ['Infrastructure'],
  $state                = 'Installing',
  $type                 = 'Infrastructure',
  $file_path            = '/etc/prodstatus', # Changing this will break the facts.
  $type_extra           = undef,
  $fact_location        = '/etc/facter/facts.d', # Default in puppet, other modules handle this path.
) {
  if $ensure == 'present' {

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
  if member($all_states, $state) {
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
  else {
    notify { "${state} is not a valid state!": }
  }

  if member($allowed_server_types, $type) {
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

    if $type_extra {
      file { 'second-type-fact':
        ensure  => file,
        path    => "${fact_location}/${type_extra}.txt",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${type_extra}=${type}",
      }
    }
  }
  else {
    notify { "${type} is not a valid type!": }
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
   file_line { 'motd_type':
     ensure            => absent,
     path              => '/etc/motd',
     match             => '^Production type:',
     match_for_absence => true,
     multiple          => true,
  }
   file { 'second-type-fact':
     ensure => absent,
     path   => "${fact_location}/${type_extra}.txt",
   }
 }
}
