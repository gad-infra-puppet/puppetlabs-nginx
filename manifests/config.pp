# Class: nginx::config
#
# This module manages NGINX bootstrap and configuration
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class nginx::config(
  $worker_processes    = $nginx::params::nx_worker_processes,
  $worker_connections  = $nginx::params::nx_worker_connections,
  $keepalive_timeout   = $nginx::params::nx_keepalive_timeout,
  $proxy_set_header    = $nginx::params::nx_proxy_set_header,
  $proxy_hide_header   = $nginx::params::nx_proxy_hide_header,
  $confd_purge         = $nginx::params::nx_confd_purge
) inherits nginx::params {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { "${nginx::params::nx_conf_dir}":
    ensure => directory,
  }

  file { 
    [
      "${nginx::params::nx_conf_dir}/conf.d", 
      "${nginx::params::nx_conf_dir}/rules.d",
      "${nginx::params::nx_conf_dir}/includes",
    ]:
    ensure => directory,
  }
  if $confd_purge == true {
    File["${nginx::params::nx_conf_dir}/conf.d"] {
      ignore => "vhost_autogen.conf",
      purge => true,
      recurse => true,
    }

    File["${nginx::params::nx_conf_dir}/rules.d"] {
      purge => true,
      recurse => true,
    }
  }


  file { "${nginx::config::nx_run_dir}":
    ensure => directory,
  }

  file { "${nginx::config::nx_client_body_temp_path}":
    ensure => directory,
    owner  => $nginx::params::nx_daemon_user,
  }

  file {"${nginx::config::nx_proxy_temp_path}":
    ensure => directory,
    owner  => $nginx::params::nx_daemon_user,
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
  }

  file { "${nginx::params::nx_conf_dir}/nginx.conf":
    ensure  => file,
    content => template('nginx/conf.d/nginx.conf.erb'),
  }

  file { "${nginx::params::nx_conf_dir}/conf.d/proxy.conf":
    ensure  => file,
    content => template('nginx/conf.d/proxy.conf.erb'),
  }

  file { "${nginx::config::nx_temp_dir}/nginx.d":
    ensure  => directory,
    purge   => true,
    recurse => true,
  }

  file { "/etc/nginx/htpasswd.users":
    ensure  => file,
    source  => "puppet:///modules/nginx/htpasswd.users"
  }
}
