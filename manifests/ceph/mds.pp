class sunfire::ceph::mds (
  $enable_mds            = true,
  $mds_activate          = true,
  $mds_data              = '/var/lib/ceph/mds/$cluster-$id',
  $keyring               = '/var/lib/ceph/mds/$cluster-$id/keyring',
  $mds_name              = $::hostname,
  $host                  = $::hostname,
  ) {
    include ::sunfire::ceph::params

    if enable_mds {
      class { "ceph::mds":
        mds_activate          => $mds_activate,
        mds_data              => $mds_data,
        keyring               => $keyring,
      } ->
      # here, you can insert other items
      ceph_config {
        "mds.${mds_name}/host":         value => $host;
        "mds.${mds_name}/mds_data":     value => "/var/lib/ceph/mds/ceph-${mds_name}/";
        "mds.${mds_name}/keyring":      value => "/var/lib/ceph/mds/ceph-${mds_name}/keyring";
      }
   ->
      service { "mds.${rgw_name}":
        ensure => running,
        start => "/etc/init.d/ceph start mds.${mds_name}",
        stop => "/etc/init.d/ceph stop mds.${mds_name}",
        status => "/etc/init.d/ceph status mds.${mds_name}",
     }
   }
  }
