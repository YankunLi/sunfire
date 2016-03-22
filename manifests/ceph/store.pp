# ===class sunfire::ceph::mon
# install and config ceph osds

# ===Authors
# Author Name liyankun
#Copyright 2016 liyankun


class sunfire::ceph::store (
  $ensure                     = present,
  $fsid                       = '066F558C-6789-4A93-AAF1-5AF1BA01A3AD',
  $cluster                    = undef,
  $authentication_type        = 'cephx',
  $mon_initial_members        = 'ceph-1,ceph-2,ceph-3',
  $mon_hosts                  = '127.0.0.1',
  $public_network             = undef,
  $cluster_network            = undef,

  $enable_monitor             = false,
  $host                       = $::hostname,
  $mon_addr                   = $::ipaddress,

  $enable_osd                 = false,
  $osd_device_dict            = {},
  $osd_journal_size           = '10240',
  $disk_type                  = 'ssd',

  $enable_rgw                 = false,

  $enable_mds                 = false,

  $keyring                    = undef,
  $admin_key                  = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',
  $mon_key                    = 'AQDesGZSsC7KJBAAw+W/Z4eGSQGAIbxWjxjvfw==',
  $bootstrap_osd_key          = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',

  $mon_osd_full_ratio         = '0.95',
  $mon_osd_nearfull_ratio     = '0.85',
  $ceph_common_conf_sata_args = undef,
  $ceph_common_conf_ssd_args  = undef,
  ){

  #configure package repository
  class { 'ceph::repo': }

  # install and configure ceph
  class { 'ceph':
    fsid                   => $fsid,
    mon_host               => $mon_hosts,
    mon_initial_members    => $mon_initial_members,
    authentication_type    => $authentication_type,
    osd_journal_size       => $osd_journa_size,
    public_network         => $public_network,
    cluster_network        => $cluster_network,
    mon_osd_full_ratio     => $mon_osd_full_ratio,
    mon_osd_nearfull_ratio => $mon_osd_nearfull_ratio,
  }

  #provie ceph special configuration
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

  #enable ceph monitor
  if $ensure == present {
    $mon_id = $::hostname
    $mon_data = "/var/lib/ceph/mon/ceph-${mon_id}"
    ceph::mon { $mon_id:
      ensure                 => present,
      key                    => $mon_key,
      authentication_type    => $authentication_type,
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
  # initializing osd
  if $enable_osd {
    $osd_data_device_list = keys($osd_device_dict)

    each($osd_data_device_list) |$key| {
      $osd_data_name = $key
      if $osd_device_dict[$key] == '' {
        ceph::osd { $osd_data_name:
          ensure           => $ensure,
          cluster          => $cluster,
        }
      } else {
        $osd_journal_name = $osd_device_dict[$key]
        ceph::osd { $osd_data_name:
          ensure           => $ensure,
          cluster          => $cluster,
          journal          => $osd_journal_name,
        }
      } 
    }
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

#  ceph::key {'client.bootstrap-osd':
#    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
#    secret       => $bootstrap_osd_key,
#  }
}
