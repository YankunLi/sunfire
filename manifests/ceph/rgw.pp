class sunfire::ceph::rgw (
#  $pkg_radosgw        = $::ceph::params::pkg_radosgw,
  $rgw_ensure         = 'running',
  $rgw_enable         = true,
  $rgw_name           = $::hostname,
#  $rgw_data           = "/var/lib/ceph/radosgw/ceph-${name}",
  $user               = root,
#  $keyring_path       = "/etc/ceph/ceph.client.${name}.keyring",
#  $log_file           = '/var/log/ceph/radosgw.log',
  $rgw_dns_name       = $::fqdn,
#  $rgw_socket_path    = $::ceph::params::rgw_socket_path,
#  $rgw_print_continue = false,
#  $rgw_port           = undef,
   $frontend_type      = 'civetweb',
#  $rgw_frontends      = 'civetweb port=7480',
  $syslog             = true,
  ) {
    # install and configure rgw
    ceph::rgw { $rgw_name:
      user               => $user,
      frontend_type      => $frontend_type,
      rgw_frontends      => $rgw_frontends,
    }

  }
