# ===class sunfire::ceph::mon
# install and config ceph osds

# ===Authors
# Author Name liyankun
#Copyright 2016 liyankun


class sunfire::ceph::osd (
  $ensure                 = present,
  $cluster                = 'ceph',
  $osd_device_dict        = {},
  $osd_journal_size       = '10240',
  ){

  # initializing osd
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
