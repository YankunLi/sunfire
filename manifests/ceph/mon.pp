# ===class sunfire::ceph::mon

# install and config ceph monitor

# ===Authors

# Author Name liyankun

# Copyright 2016 liyankun 


class sunfire::ceph::mon (
  $ensure                     = present,
  $authentication_type        = 'cephx',
  $cluster                    = undef,
  $mon_addr                   = $::ipaddress,
  $host                       = $::hostname,
  $mon_key                    = 'AQDesGZSsC7KJBAAw+W/Z4eGSQGAIbxWjxjvfw==',
  ) {

    $mon_id = $::hostname
    $mon_data = "/var/lib/ceph/mon/ceph-${mon_id}"

    # Install and configure ceph monitors
    if $ensure == present {
      ceph::mon { $mon_id:
        ensure                 => present,
        key                    => $mon_key,
        authentication_type    => $authentication_type,
      }
#
      ceph_config {
        "mon.${mon_id}/host":                         value => $host;
        "mon.${mon_id}/mon_data":                     value => $mon_data;
        "mon.${mon_id}/mon_addr":                     value => "${mon_addr}:6789";
      }

    } else {
      ceph::mon { $::hostname:
       ensure                  => absent,
      }
    }
  }
