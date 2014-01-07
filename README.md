#collectd

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Resources managed by collectd module](#resources-managed-by-collectd-module)
    * [Setup requirements](#setup-requirements)
    * [Beginning with module collectd](#beginning-with-module-collectd)
4. [Usage](#usage)
5. [Operating Systems Support](#operating-systems-support)
6. [Development](#development)

##Overview

This module installs, manages and configures collectd.

##Module Description

The module is based on **stdmod** naming standards version 0.9.0.

Refer to http://github.com/stdmod/ for complete documentation on the common parameters.


##Setup

###Resources managed by collectd module
* This module installs the collectd package
* Enables the collectd service
* Can manage all the configuration files (by default no file is changed)
* Can install and configure collectd plugins

###Setup Requirements
* PuppetLabs [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* StdMod [stdmod module](https://github.com/stdmod/stdmod)
* Puppet version >= 2.7.x
* Facter version >= 1.6.2

###Beginning with module collectd

To install the package provided by the module just include it:

        include collectd

The main class arguments can be provided either via Hiera (from Puppet 3.x) or direct parameters:

        class { 'collectd':
          parameter => value,
        }

The module provides also a generic define to manage any collectd configuration file:

        collectd::conf { 'sample.conf':
          content => '# Test',
        }

You can place the configurations of a plugin either in the main config file or in a file managed with the generic define collect::conf or with the dedicated define collectd::plugin (which can also install the relevant package):

        collectd::plugin { 'mysql':
          config_file_template     => 'site/collectd/plugin/mysql.erb',
          config_file_options_hash => {
            host     => 'localhost',
            user     => 'wordpress',
            password => 'secret',
            database => 'wordpress',
          },
          package_install          => true,  # Default: false
        }


A custom plugin template is available as well:

          collectd::plugin { 'rrdtool':
            config_file_options_hash => {
              'DataDir'         => '"/var/lib/collectd/"',
              'RRARows'         => '1337',
              'RRATimespan'     => [ '10',
                                     '100',
                                     '1000' ],
              'XFF'             => '0.25',
            }
          }

This results in:

  <Plugin rrdtool>
      DataDir       "/var/lib/collectd/"
      RRARows       1337
      RRATimespan   10
      RRATimespan   100
      RRATimespan   1000
      XFF           0.25
  </Plugin>


##Usage

* A common way to use this module involves the management of the main configuration file via a custom template (provided in a custom site module):

        class { 'collectd':
          config_file_template => 'site/collectd/collectd.conf.erb',
        }

* You can write custom templates that use setting provided but the config_file_options_hash paramenter

        class { 'collectd':
          config_file_template      => 'site/collectd/collectd.conf.erb',
          config_file_options_hash  => {
            opt  => 'value',
            opt2 => 'value2',
          },
        }

* Use custom source (here an array) for main configuration file. Note that template and source arguments are alternative.

        class { 'collectd':
          config_file_source => [ "puppet:///modules/site/collectd/collectd.conf-${hostname}" ,
                                  "puppet:///modules/site/collectd/collectd.conf" ],
        }

* You can provide a custom template (or content or source) also for the init configuration script for which eventually use a dedicated config hash with init_config_file_options_hash paramenter

        class { 'collectd':
          init_config_file_template      => 'site/collectd/collectd.init.erb',
          init_config_file_options_hash  => {
            opt  => 'value',
            opt2 => 'value2',
          },
        }

* Use custom source directory for the whole configuration directory, where present.

        class { 'collectd':
          config_dir_source  => 'puppet:///modules/site/collectd/conf/',
        }

* Use custom source directory for the whole config.d directory (on RedHat family config_dir_path == confd_dir_path).

        class { 'collectd':
          confd_dir_source  => 'puppet:///modules/site/collectd/collectd.d',
        }

* Use custom source directory for the whole configuration directory and purge all the local files that are not on the dir.
  Note: This option can be used to be sure that the content of a directory is exactly the same you expect, but it is desctructive and may remove files.

        class { 'collectd':
          config_dir_source => 'puppet:///modules/site/collectd/conf/',
          config_dir_purge  => true, # Default: false.
        }

* Use custom source directory for the whole configuration dir and define recursing policy.

        class { 'collectd':
          config_dir_source    => 'puppet:///modules/site/collectd/conf/',
          config_dir_recursion => false, # Default: true.
        }

* Do not trigger a service restart when a config file changes.

        class { 'collectd':
          config_dir_notify => '', # Default: Service[collectd]
        }


##Operating Systems Support

This is tested on these OS:
- RedHat osfamily 5 and 6
- Debian 6 and 7
- Ubuntu 10.04 and 12.04


##Development

Pull requests (PR) and bug reports via GitHub are welcomed.

When submitting PR please follow these quidelines:
- Provide puppet-lint compliant code
- If possible provide rspec tests
- Follow the module style and stdmod naming standards

When submitting bug report please include or link:
- The Puppet code that triggers the error
- The output of facter on the system where you try it
- All the relevant error logs
- Any other information useful to undestand the context
