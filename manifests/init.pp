# == Class: prodstatus
#
# This module manages the production status of a machine and sets banners
# acordingly.
#

class prodstatus (
  $allowed_states       = {
    pre_prod => ['Installing', 'PoC', 'Sandbox'],
    prod     => ['In Production'],
    decom    => ['Decomissioned'] },
  $allowed_server_types = ['Infrastructure'],
  $state                = 'Installing',
  $type                 = 'Infrastructure',
  $file_path            = '/etc/prodstatus', # Changing this will break the facts.
) {

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
  }
  else {
    notify { "${type} is not a valid type!": }
  }
}
