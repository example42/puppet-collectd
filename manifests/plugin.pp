#
# = Define: collectd::plugin
#
# With this define you can manage install and configure collectd plugins
#
# == Parameters
#
# [*ensure*]
#   String. Default: present
#   Manages the plugin presence. Possible values:
#   * 'present' - Create and manages the file.
#   * 'absent' - Remove the file.
#
# [*config_file_template*]
#   String. Optional. Default: undef. Alternative to: config_file_source,
#   and config_file_content.
#   Sets the module path of a custom template to use as content of
#   the config file for this plugin.
#   When defined, the plugin config file has: content => content($config_file_template),
#   Example: config_file_template => 'site/collectd/my.conf.erb',
#
# [*config_file_content*]
#   String. Optional. Default: undef. Alternative to: config_file_template,
#   and config_file_source.
#   Sets directly the value of the file's content parameter
#   When defined, config file has: content => $config_file_content,
#   Example: config_file_content => "# File manage by Puppet \n",
#
# [*config_file_source*]
#   String. Optional. Default: undef. Alternative to: config_file_template,
#   and config_file_content.
#   Sets the value of the file's source parameter
#   When defined, config file has: source => $config_file_source,
#   Example: config_file_source => 'puppet:///site/collectd/my.conf',
#
# [*config_file_path*]
#   String. Optional. Default: $collect::confd_dir_path/${name}.conf
#   The path where to place the plugin configuration file.
#   Note that you need in your collectd.conf to include the $collectd::confd_dir_path
#   directory. For example, in a template:
#   Include      "<%= scope.lookupvar('collectd::confd_dir_path') %>"
#
# [*config_file_mode*]
# [*config_file_owner*]
# [*config_file_group*]
# [*config_file_notify*]
# [*config_file_require*]
#   String. Optional. Default: undef
#   All these parameters map directly to the created file attributes.
#   If not defined the module's defaults are used.
#   If defined, the plugin config file file has, for example: mode => $mode
#
# [*config_file_options_hash*]
#   Hash. Default undef. Needs: 'config_file_template'.
#   An hash of custom options to be used in templates to manage any key pairs of
#   arbitrary settings.
#
# [*package_install*]
#  Boolean. Default: false
#  Define if you want to install a package with the plugin name (ie: collectd-${name})
#
# [*package_name*]
#  String. Optional. Default: undef
#  Name of the package to install. Default is collectd-${name}
#
define collectd::plugin (

  $ensure                   = present,

  $config_file_source       = undef,
  $config_file_template     = undef,
  $config_file_content      = undef,
  $config_file_options_hash = undef,

  $config_file_path         = undef,
  $config_file_mode         = undef,
  $config_file_owner        = undef,
  $config_file_group        = undef,
  $config_file_notify       = 'class_default',
  $config_file_require      = undef,

  $package_install          = false,
  $package_name             = undef,

) {

  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent. WARNING: If set to absent the conf file is removed.')

  include collectd

  if $config_file_options_hash and ! $config_file_content and ! $config_file_template {
    $use_config_file_content = template('collectd/plugin.erb')
  } else {
    $use_config_file_content = undef
  }

  $manage_path    = pickx($config_file_path, "${collectd::confd_dir_path}/${name}.conf")
  $manage_content = default_content($use_config_file_content, $config_file_template)
  $manage_mode    = pickx($config_file_mode, $collectd::config_file_mode)
  $manage_owner   = pickx($config_file_owner, $collectd::config_file_owner)
  $manage_group   = pickx($config_file_group, $collectd::config_file_group)
  $manage_require = pickx($config_file_require, $collectd::config_file_require)
  $manage_notify  = $config_file_notify ? {
    'class_default' => $collectd::manage_config_file_notify,
    default         => $config_file_notify,
  }
  $manage_package_name = pickx($package_name, "collectd-${name}")

  if $package_install {
    package { "collectd_plugin_${name}":
      ensure   => $ensure,
      name     => $manage_package_name,
      before   => File["collectd_plugin_${name}.conf"],
    }
  }

  file { $manage_path:
    ensure  => $ensure,
    source  => $config_file_source,
    content => $manage_content,
    mode    => $manage_mode,
    owner   => $manage_owner,
    group   => $manage_group,
    require => $manage_require,
    notify  => $manage_notify,
    alias   => "collectd_plugin_${name}.conf",
  }

}
