# Class: collectd::params
#
# Defines all the variables used in the module.
#
class collectd::params {

  $package_name = $::osfamily ? {
    default => 'collectd',
  }

  $service_name = $::osfamily ? {
    default => 'collectd',
  }

  $config_file_path = $::osfamily ? {
    'RedHat'=> '/etc/collectd.conf',
    default => '/etc/collectd/collectd.conf',
  }

  $config_file_mode = $::osfamily ? {
    default => '0644',
  }

  $config_file_owner = $::osfamily ? {
    default => 'root',
  }

  $config_file_group = $::osfamily ? {
    default => 'root',
  }

  $config_dir_path = $::osfamily ? {
    'RedHat' => '/etc/collectd.d',
    default  => '/etc/collectd',
  }

  $confd_dir_path = $::osfamily ? {
    'RedHat' => '/etc/collectd.d',
    default  => '/etc/collectd/collectd.d',
  }

  $init_config_file_path = $::osfamily ? {
    'Redhat' => '/etc/sysconfig/collectd',
    'Debian' => '/etc/default/collectd',
    default  => '',
  }

  case $::osfamily {
    'Debian','RedHat','Amazon': { }
    default: {
      fail("${::operatingsystem} not supported. Review params.pp for extending support.")
    }
  }
}
