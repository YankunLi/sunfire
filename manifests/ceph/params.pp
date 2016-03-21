class ceph::params {

  # install
  $package_name                 = 'ceph'
  $release                      = 'dumpling'
  $package_ensure               = 'present'
  $ceph_yum_repo_enable         = false
  $path                         = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  $timeout                      = 3

  # cluster config
  $fsid                         = '27d39faa-48ae-4356-a8e3-19d5b81e179e'
  $debug_enable                 = false
  $perf                         = true
  $mutex_perf_counter           = false
  $syslog_enable                = false

  # auth config
  $auth_enable                  = true
  $common_key                   = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $mon_key                      = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $admin_key                    = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $mds_key                      = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $bootstrap_osd_key            = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $openstack_key                = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
  $radosgw_key                  = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='

  # ratio
  $mon_osd_full_ratio           = '0.95'
  $mon_osd_nearfull_ratio       = '0.85'

  # osd pool
  $osd_pool_default_pg_num      = 2048
  $osd_pool_default_pgp_num     = 2048
  $osd_pool_default_min_size    = 1
  $osd_pool_default_size        = 2
  $osd_pool_default_crush_rule  = 'rbd'
  $osd_crush_chooseleaf_type    = 'host'

  # osd heartbeat
  $osd_heartbeat_interval       = 3 # we need smapp interval to reduce slow requests
  $osd_heartbeat_grace          = 7 # we need small setting to reduce slow requests
  $osd_heartbeat_min_peers      = 10
  $osd_mon_heartbeat_interval   = 30

  # osd filestore
  $filestore_fd_cache_size      = 204800 # we need more fd cache size

  # osd xfs options
  $osd_xfs_mount_options         = 'rw,noexec,nodev,noatime,nodiratime,barrier=0,discard,inode64,logbsize=256k,delaylog'
  $osd_xfs_mkfs_options          = "-f -n size=64k -i size=512 -d agcount=${::processorcount} -l size=1024m"

  # osd start option
  $osd_crush_update_on_start     = false # because we need our crush map and policy, we don't need auto update crush map on start

  # mon osd interaction
  $mon_osd_adjust_heartbeat_grace    = false # we don't need mon to adjust heartbeat grace, it will lose control
  $mon_osd_adjust_down_out_interval  = false # we don't need mon to adjust down out interval
  $mon_osd_down_out_interval         = 43200 # the defaut is 300 , our first setting is 20 mins, second setting is 12 hoours
  
  # crush tuning
  $mon_warn_on_legacy_crush_tunables = false


  # rbd
  $rbd_cache                           = false
  $rbd_cache_size                      = 134217728 #OPT_LONGLONG
  $rbd_cache_max_dirty                 = 134217728
  $rbd_cache_target_dirty              = 33554432
  $rbd_cache_max_dirty_age             = 30
  $rbd_cache_writethrough_until_flush  = true

  # rgw
  $rgw_keystone_accepted_roles           = "admin, staff, _member_"
  $rgw_frontends                         = "civetweb port=7480"
  $rgw_enable_apis                       = "s3, admin"
  $rgw_enable_usage_log                  = true
  $rgw_keystone_token_cache_size         = 10000
  $rgw_keystone_revocation_interval      = 9000
  $nss_db_path                           = '/var/ceph/nss'
  $rgw_print_continue                    = false
  $rgw_override_bucket_index_max_shards  = 0
  $rgw_cache_enabled                     = true
  $rgw_cache_lru_size                    = 10000
  $rgw_num_rados_handles                 = 20
  $rgw_swift_token_expiration            = 86400
  $rgw_thread_pool_size                  = 200


}
