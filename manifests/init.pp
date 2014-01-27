#
# = Class: collectd
#
# This class installs and manages collectd
#
#
# == Parameters
#
# Refer to https://github.com/stdmod for official documentation
# on the stdmod parameters used
#
class collectd (

  $package_name              = $collectd::params::package_name,
  $package_ensure            = 'present',

  $service_name              = $collectd::params::service_name,
  $service_ensure            = 'running',
  $service_enable            = true,

  $config_file_path          = $collectd::params::config_file_path,
  $config_file_require       = 'Package[collectd]',
  $config_file_notify        = 'Service[collectd]',
  $config_file_replace       = true,
  $config_file_source        = undef,
  $config_file_template      = undef,
  $config_file_content       = undef,
  $config_file_options_hash  = { } ,

  $config_dir_path           = $collectd::params::config_dir_path,
  $config_dir_source         = undef,
  $config_dir_purge          = false,
  $config_dir_recurse        = true,

  $confd_dir_path            = $collectd::params::confd_dir_path,
  $confd_dir_source          = undef,
  $confd_dir_purge           = false,
  $confd_dir_recurse         = true,

  $init_config_file_path          = $collectd::params::init_config_file_path,
  $init_config_file_source        = undef,
  $init_config_file_template      = undef,
  $init_config_file_content       = undef,
  $init_config_file_options_hash  = { } ,

  $dependency_class          = undef,
  $my_class                  = undef,

  $monitor_class             = undef,
  $monitor_options_hash      = { } ,

  $firewall_class            = undef,
  $firewall_options_hash     = { } ,

  $scope_hash_filter         = '(uptime.*|timestamp)',

  $tcp_port                  = undef,
  $udp_port                  = undef,

  ) inherits collectd::params {


  # Class variables validation and management

  validate_bool($service_enable)
  validate_bool($config_dir_recurse)
  validate_bool($config_dir_purge)
  validate_bool($confd_dir_recurse)
  validate_bool($confd_dir_purge)
  if $config_file_options_hash { validate_hash($config_file_options_hash) }
  if $init_config_file_options_hash { validate_hash($init_config_file_options_hash) }
  if $monitor_options_hash { validate_hash($monitor_options_hash) }
  if $firewall_options_hash { validate_hash($firewall_options_hash) }

  $config_file_owner          = $collectd::params::config_file_owner
  $config_file_group          = $collectd::params::config_file_group
  $config_file_mode           = $collectd::params::config_file_mode
  $manage_config_file_content = default_content($config_file_content, $config_file_template)
  $manage_init_config_file_content = default_content($init_config_file_content, $init_config_file_template)
  $manage_config_file_notify  = $config_file_notify ? {
    'class_default' => 'Service[collectd]',
    ''              => undef,
    default         => $config_file_notify,
  }
  if $package_ensure == 'absent' {
    $manage_service_enable = undef
    $manage_service_ensure = stopped
    $config_dir_ensure = absent
    $config_file_ensure = absent
  } else {
    $manage_service_enable = $service_enable
    $manage_service_ensure = $service_ensure
    $config_dir_ensure = directory
    $config_file_ensure = present
  }


  # Prerequisites

  if $collectd::dependency_class {
    include $collectd::dependency_class
  }


  # Resources managed

  if $collectd::package_name {
    package { 'collectd':
      ensure   => $collectd::package_ensure,
      name     => $collectd::package_name,
    }
  }

  if $collectd::config_file_path {
    file { $collectd::config_file_path:
      ensure  => $collectd::config_file_ensure,
      mode    => $collectd::config_file_mode,
      owner   => $collectd::config_file_owner,
      group   => $collectd::config_file_group,
      source  => $collectd::config_file_source,
      content => $collectd::manage_config_file_content,
      notify  => $collectd::manage_config_file_notify,
      require => $collectd::config_file_require,
      alias   => 'collectd.conf',
    }
  }

  if $collectd::init_config_file_path {
    file { $collectd::init_config_file_path:
      ensure  => $collectd::config_file_ensure,
      mode    => $collectd::config_file_mode,
      owner   => $collectd::config_file_owner,
      group   => $collectd::config_file_group,
      source  => $collectd::init_config_file_source,
      content => $collectd::manage_init_config_file_content,
      notify  => $collectd::manage_config_file_notify,
      require => $collectd::config_file_require,
      alias   => 'collectd.init.conf',
    }
  }

  if $collectd::config_dir_source {
    file { $collectd::config_dir_path:
      ensure  => $collectd::config_dir_ensure,
      source  => $collectd::config_dir_source,
      recurse => $collectd::config_dir_recurse,
      purge   => $collectd::config_dir_purge,
      force   => $collectd::config_dir_purge,
      require => $collectd::config_file_require,
      alias   => 'collectd.dir',
    }
  }

  if $collectd::confd_dir_path {
    file { $collectd::confd_dir_path:
      ensure  => $collectd::config_dir_ensure,
      source  => $collectd::confd_dir_source,
      recurse => $collectd::confd_dir_recurse,
      purge   => $collectd::confd_dir_purge,
      force   => $collectd::confd_dir_purge,
      alias   => 'collectd_d.dir',
    }
  }

  if $collectd::service_name {
    service { 'collectd':
      ensure     => $collectd::manage_service_ensure,
      name       => $collectd::service_name,
      enable     => $collectd::manage_service_enable,
    }
  }


# Extra classes

  if $collectd::my_class {
    include $collectd::my_class
  }

  if $collectd::monitor_class {
    class { $collectd::monitor_class:
      options_hash => $collectd::monitor_options_hash,
      scope_hash   => {}, # TODO: Find a good way to inject class' scope
    }
  }

  if $collectd::firewall_class {
    class { $collectd::firewall_class:
      options_hash => $collectd::firewall_options_hash,
      scope_hash   => {},
    }
  }

}
