# ===class sunfire::ceph::mon
# install and config ceph osds

# ===Authors
# Author Name liyankun
#Copyright 2016 liyankun


class sunfire::ceph::osd (
  $ensure                 = present,
  $enable_osd             = true,
  $cluster                = 'ceph',
  $osd_storage_type       = 'ssd',
  $osd_device_dict        = {},
  $fsid                   = '066F558C-6789-4A93-AAF1-5AF1BA01A3AD',
  $mon_initial_members    = 'ceph-1,ceph-2,ceph-3',
  $mon_hosts              = '127.0.0.1',
  $bootstrap_osd_key      = 'AQABsWZSgEDmJhAAkAGSOOAJwrMHrM5Pz5On1A==',
  $osd_journal_size       = '10240',
  $mon_osd_full_ratio     = '0.95',
  $mon_osd_nearfull_ratio = '0.85',
  ){

  #configure package repository
  class { 'ceph::repo': }

  # install and configure ceph
  class { 'ceph':
    fsid                   => $fsid,
    osd_journal_size       => $osd_journa_size,
    mon_osd_full_ratio     => $mon_osd_full_ratio,
    mon_osd_nearfull_ratio => $mon_osd_nearfull_ratio,
    mon_initial_members    => $mon_initial_members,
    mon_host               => $mon_hosts,
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
  
  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }
}
