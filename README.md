# puppet-module-production-status
Classification of a server in what production status it is.


# Parameters prodstatus

allowed_states
--------------
An array of allowed states for a server. To force people to write accroding to a set standard

- *Default*: allowed_states = {
    pre_prod ['Installing', 'PoC', 'Sandbox'],
    prod     ['In Production'],
    decom    ['Decomissioned'] }

allowed_server_types
--------------
An array of allowed server types. To force people to write accroding to a set standard

- *Default*: ['Infrastructure']

state
-----
The current state your server is in.

- *Default*: 'Installing'

type
----
What function does your server fil?

- *Default*: 'Infrastructure'

file_path
---------
The location of the prodstatus files. Do not change this location since it will destory the fact generation.

- *Default*: '/etc/prodstatus'

type_extra
--------------
An extra way of definnig what the type fact should be called.
This is only for handeling a specific case where i have to be able to 
call this module something else then production_type.

- *Default*: undef

fact_location
--------------
Path for pointing out the location for facts.
This module don't handle the creating of this path.

- *Default*: '/etc/facter/facts.d'

hiera_example
-------------
prodstatus::allowed_server_types:
  - 'Infrastructure'
  - 'Customerserver'
  - 'Terminal'
prodstatus::allowed_states:
  pre_prod:
    - 'Installing'
    - 'PoC'
    - 'Sandbox'
  prod:
    - 'In Production'
  decom:
    - 'Decomissioned'
