# ===class sunfire::ceph::mon
# install and config ceph osds

# ===Authors
# Author Name liyankun
#Copyright 2016 liyankun


class sunfire::ceph::store (
  $ensure                       = present,
  $fsid                         = '066F558C-6789-4A93-AAF1-5AF1BA01A3AD',
  $cluster                      = undef,
  $authentication_type          = 'cephx',
  $mon_initial_members          = 'ceph-1,ceph-2,ceph-3',
  $mon_hosts                    = '127.0.0.1',
  $public_network               = undef,
  $cluster_network              = undef,

  $enable_mon                   = false,
  $host                         = $::hostname,
  $mon_addr                     = $::ipaddress,

  $enable_osd                   = false,
  $osd_device_dict              = {},
  $osd_journal_size             = '10240',
  $disk_type                    = 'ssd',

  $enable_rgw                   = false,
  $rgw_ensure                   = 'running',
  $user                         = root,
  $frontend_type                = 'civetweb',
  $rgw_frontends                = "civetweb port=7480",
  $rgw_enable_apis              = "s3, admin",
  $rgw_s3_auth_use_keystone     = true,
  $rgw_keystone_url             = "http://keyston.com:35357/",
  $rgw_keystone_admin_token     = "admin",
  $rgw_keystone_accepted_roles  = "_member_, admin",
  $rgw_dns_name                 = undef,

  $enable_mds                   = false,

  $pool_name                    = 'openstack-00',
  $pg_num                       = 64,
  $pgp_num                      = undef,
  $size                         = undef,

  $keyring                      = undef,
  $admin_key                    = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',
  $rgw_key                      = 'AQCTg71RsNIHORAAW+O6FCMZWBjmVfMIPk3MhQ==',
  $mon_key                      = 'AQDesGZSsC7KJBAAw+W/Z4eGSQGAIbxWjxjvfw==',
  $bootstrap_osd_key            = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',
  $mds_key                      = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',

  $mon_osd_full_ratio           = '0.95',
  $mon_osd_nearfull_ratio       = '0.85',
  $ceph_common_conf_sata_args   = undef,
  $ceph_common_conf_ssd_args   = undef,
  ){

#  firewall { '100 allow OSD access':
#    port   => ['6800-7000'],
#    proto  => tcp,
#    action => accept,
#  }
#
#  firewall { '101 allow ssh access':
#    port   => [22],
#    proto  => tcp,
#    action => accept,
#  }
  #configure package repository
#  class { 'ceph::repo': }

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
  if $enable_mon {
    class {'sunfire::ceph::mon':
      ensure                   => present,
      authentication_type      => $authentication_type,
      cluster                  => $cluster,
      mon_addr                 => $mon_addr,
      mon_key                  => $mon_key,
      host                     => $host,
    }
 #   Ceph::Key {
 #     inject         => true,
 #     inject_as_id   => 'mon.',
 #     inject_keyring => "/var/lib/ceph/mon/ceph-${host}/keyring",
 #   }
 #   ceph::key { 'client.admin':
 #     secret  => $admin_key,
 #     cap_mon => 'allow *',
 #     cap_osd => 'allow *',
 #     cap_mds => 'allow',
 #   }
 #   ceph::key { 'client.bootstrap-osd':
 #     secret  => $bootstrap_osd_key,
 #     cap_mon => 'allow profile bootstrap-osd',
 #   }
  }
  if $enable_mon {
    Ceph::Key {
      inject         => true,
      inject_as_id   => 'mon.',
      inject_keyring => "/var/lib/ceph/mon/ceph-${host}/keyring",
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
  } else {
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
  }
#  if $ensure == present {
#    $mon_id = $::hostname
#    $mon_data = "/var/lib/ceph/mon/ceph-${mon_id}"
#    ceph::mon { $mon_id:
#      ensure                 => present,
#      key                    => $mon_key,
#      authentication_type    => $authentication_type,
#    }
#
#    ceph_config {
#      "mon.${mon_id}/host":                         value => $host;
#      "mon.${mon_id}/mon_data":                     value => $mon_data;
#      "mon.${mon_id}/mon_addr":                     value => "${mon_addr}:6789";
#    }
#
#  } else {
#    ceph::mon { $::hostname:
#      ensure                  => absent,
#    }
#  }
#
  # initializing osd
  if $enable_osd {
    class {'sunfire::ceph::osd':
    ensure                     => present,
    cluster                   => $cluster,
    osd_device_dict           => $osd_device_dict,
    osd_journal_size          => $osd_journal_size,
    }
#    ceph::key { 'client.bootstrap-osd':
#      secret  => $bootstrap_osd_key,
#      cap_mon => 'allow profile bootstrap-osd',
#    }
  }

#  if $enable_osd {
#    $osd_data_device_list = keys($osd_device_dict)
#
#    each($osd_data_device_list) |$key| {
#      $osd_data_name = $key
#      if $osd_device_dict[$key] == '' {
#        ceph::osd { $osd_data_name:
#          ensure           => $ensure,
#          cluster          => $cluster,
#        }
#      } else {
#        $osd_journal_name = $osd_device_dict[$key]
#        ceph::osd { $osd_data_name:
#          ensure           => $ensure,
#          cluster          => $cluster,
#          journal          => $osd_journal_name,
#        }
#      } 
#    }
#  }
#
  if $enable_rgw  {
#    firewall { '102 allow rgw access':
#      port   => [7480],
#      proto  => tcp,
#      action => accept,
#    }
    class { 'sunfire::ceph::rgw':
      rgw_ensure                   => $rgw_ensure,
      user                         => $user,
      frontend_type                => $frontend_type,
      rgw_frontends                => $rgw_frontends,
      rgw_enable_apis              => $rgw_enable_apis,
      rgw_s3_auth_use_keystone     => $rgw_s3_auth_use_keystone,
      rgw_keystone_url             => $rgw_keystone_url,
      rgw_keystone_admin_token     => $rgw_keystone_admin_token,
      rgw_keystone_accepted_roles  => $rgw_keystone_accepted_roles,
      rgw_dns_name                 => $rgw_dns_name,
      rgw_name                     => $host,
    }

    if ! $enable_mon {
      Ceph::Key {
        inject         => true,
        inject_as_id   => 'client.admin',
        inject_keyring => "/etc/ceph/ceph.client.admin.keyring",
      }
    }

    ceph::key { "client.radosgw.${host}":
      secret       => $rgw_key,
      cap_mon      => 'allow *',
      cap_osd      => 'allow *',
      cap_mds      => 'allow',
    }
  }
#install mds 
  if $enable_mds {
    class { "sunfire::ceph::mds":
    enable_mds           => $enable_mds,
    mds_activate         => $enable_mds,
    mds_name             => $host,
    }

    if ! $enable_mon {
      Ceph::Key {
        inject         => true,
        inject_as_id   => 'client.admin',
        inject_keyring => "/etc/ceph/ceph.client.admin.keyring",
      }
    }

    ceph::key { "mds.${host}":
      secret       => $mds_key,
      cap_mon      => 'allow *',
      cap_osd      => 'allow *',
      cap_mds      => 'allow *',
      keyring_path => "/var/lib/ceph/mds/ceph-${host}/keyring",
    }
  }

  
#  ceph::pool { "${pool_name}":
#    ensure       => present,
#    pg_num       => $pg_num,
#    pgp_num      => $pgp_num,
#    size         => $size,
#  }
#  ceph::key {'client.bootstrap-osd':
#    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
#    secret       => $bootstrap_osd_key,
#  }
}
