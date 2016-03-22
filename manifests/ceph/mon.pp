# ===class sunfire::ceph::mon

# install and config ceph monitor

# ===Authors

# Author Name liyankun

# Copyright 2016 liyankun 


class sunfire::ceph::mon (
  $ensure                     = present,
  $enable_monitor             = true,
  $public_network             = undef,
  $cluster_network            = undef,
  $mon_members                = 'mon1,mon2,mon3',
  $mon_hosts                  = '127.0.0.1',
  $authentication_type        = 'cephx',
  $cluster                    = undef,
  $keyring                    = undef,
  $mon_addr                   = $::ipaddress,
  $host                       = $::hostname,
  $fsid                       = '066F558C-6789-4A93-AAF1-5AF1BA01A3AD',
  $admin_key                  = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',
  $mon_key                    = 'AQDesGZSsC7KJBAAw+W/Z4eGSQGAIbxWjxjvfw==',
  $bootstrap_osd_key          = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',
  $disk_type                  = 'ssd',
  $ceph_common_conf_ssd_args  = undef,
  $ceph_common_conf_sata_args = undef,
  ) {

    $mon_id = $::hostname
    $mon_data = "/var/lib/ceph/mon/ceph-${mon_id}"

    # Configure ceph repository
    class { 'ceph::repo': }

    # Install ceph commmon dependencise and configure ceph common setting
    class { 'ceph':
      fsid                => $fsid,
      mon_initial_members => $mon_members,
      mon_host            => $mon_hosts,
      authentication_type => $authentication_type,
      public_network      => $public_network,
      cluster_network     => $cluster_network,
    }

   #provide ceph special configuration
    if $disk_type == 'ssd' {
      if $ceph_common_conf_ssd_args {
        class { 'ceph::conf':
          args                => $ceph_common_conf_ssd_args
        }
      }
    } else {
      if $ceph_common_conf_sata_args {
        class { 'ceph::conf':
          args                => $ceph_common_conf_sata_args
        }
      }
    }

    # Install and configure ceph monitors
    if $ensure == present {
      ceph::mon { $mon_id:
        ensure                 => present,
        key                    => $mon_key,
        authentication_type    => $authentication_type,
      }

      Ceph::Key {
        inject         => true,
        inject_as_id   => 'mon.',
        inject_keyring => "/var/lib/ceph/mon/ceph-${mon_id}/keyring",
      }
      ceph::key { 'client.admin':
        secret  => $admin_key,
        cap_mon => 'allow *',
        cap_osd => 'allow *',
        cap_mds => 'allow',
      }
      ceph::key { 'client.bootstrap-osd':
        secret  => $bootstrap_osd_key,
        cap_mon => 'allow profile bootstrap-osd',
      }

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
