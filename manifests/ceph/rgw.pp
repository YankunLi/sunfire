class sunfire::ceph::rgw (
  $rgw_ensure                   = 'running',
  $rgw_enable                   = true,
  $rgw_name                     = $::hostname,
  $user                         = root,
  $rgw_dns_name                 = $::fqdn,
  $frontend_type                = 'civetweb',
  $rgw_frontends                = "civetweb port=7480",
  $rgw_enable_apis              = "s3, admin",
  $rgw_s3_auth_use_keystone     = false,
  $rgw_keystone_url             = "http://keyston.com:35357/",
  $rgw_keystone_admin_token     = "admin",
  $rgw_keystone_accepted_roles  = "_member_, admin",
  ) {
    # install and configure rgw
    include ::sunfire::ceph::params
 #   require ::sunfire::ceph::params

    ceph::rgw { "radosgw.${rgw_name}":
      user               => $user,
      rgw_ensure         => $rgw_ensure,
      rgw_dns_name       => $rgw_dns_name,
      frontend_type      => $frontend_type,
      rgw_frontends      => $rgw_frontends,
      rgw_print_continue => $rgw_print_continue,
      rgw_port           => 9000,
    }


    ceph_config {
      "client.radosgw.${rgw_name}/admin_socket": value => $::sunfire::ceph::params::rgw_admin_socket;
      "client.radosgw.${rgw_name}/rgw_dns_name": value => $rgw_dns_name;
      "client.radosgw.${rgw_name}/rgw_s3_auth_use_keystone": value => $rgw_s3_auth_use_keystone;
      "client.radosgw.${rgw_name}/rgw_enable_apis": value => $rgw_enable_apis;
      "client.radosgw.${rgw_name}/rgw_enable_usage_log": value => $::sunfire::ceph::params::rgw_enable_usage_log;
      "client.radosgw.${rgw_name}/rgw_override_bucket_index_max_shards": value => $::sunfire::ceph::params::rgw_override_bucket_index_max_shards;
      "client.radosgw.${rgw_name}/rgw_cache_enabled": value => $::sunfire::ceph::params::rgw_cache_enabled;
      "client.radosgw.${rgw_name}/rgw_cache_lru_size": value => $::sunfire::ceph::params::rgw_cache_lru_size;
      "client.radosgw.${rgw_name}/rgw_num_rados_handles": value => $::sunfire::ceph::params::rgw_num_rados_handles;
      "client.radosgw.${rgw_name}/rgw_swift_token_expiration": value => $sunfire::ceph::params::rgw_swift_token_expiration;
      "client.radosgw.${rgw_name}/rgw_thread_pool_size": value => $::sunfire::ceph::params::rgw_thread_pool_size;
    }
  
    if $rgw_s3_auth_use_keystone {
      ceph_config {
          "client.radosgw.${rgw_name}/nss_db_path": value => $sunfire::ceph::params::nss_db_path;
          "client.radosgw.${rgw_name}/rgw_keystone_url": value => $rgw_keystone_url;
          "client.radosgw.${rgw_name}/rgw_keystone_admin_token": value => $rgw_keystone_admin_token;
          "client.radosgw.${rgw_name}/rgw_keystone_accepted_roles": value => $rgw_keystone_accepted_roles;
          "client.radosgw.${rgw_name}/rgw_keystone_token_cache_size": value => $::sunfire::ceph::params::rgw_keystone_token_cache_size;
          "client.radosgw.${rgw_name}/rgw_keystone_revocation_interval": value => $::sunfire::ceph::params::rgw_keystone_revocation_interval;
      }
    } else {
      ceph_config {
          "client.radosgw.${rgw_name}/nss_db_path": ensure => absent;
          "client.radosgw.${rgw_name}/rgw_keystone_url": ensure => absent;
          "client.radosgw.${rgw_name}/rgw_keystone_admin_token": ensure => absent;
          "client.radosgw.${rgw_name}/rgw_keystone_accepted_roles": ensure => absent;
          "client.radosgw.${rgw_name}/rgw_keystone_token_cache_size": ensure => absent;
          "client.radosgw.${rgw_name}/rgw_keystone_revocation_interval": ensure => absent;
      }
    }
  }
