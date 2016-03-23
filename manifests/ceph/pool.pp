define sunfire::ceph::pool (
  $ensure                 = present,
  $pg_num                 = 64,
  $pgp_num                = undef,
  $size                   = undef,
  $exec_timeout = $::sunfire::ceph::params::exec_timeout,
  ) {
   ceph::pool{"${name}":
     ensure            => $ensure,
     pg_num            => $pg_num,
     pgp_num           => $pgp_num,
     size              => $size,
   }
  }
