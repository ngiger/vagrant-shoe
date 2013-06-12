# == Class: module/shoe
#
# Full description of class module/shoe here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { module/shoe:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class shoe {

  if ( $::osfamily == 'Debian') {
    include postgresql::params
    include postgresql::server
    postgresql::db { 'shoe':
      user     => 'shoe',
      password => 'lacet'
    }
    
    postgresql::role{'vagrant':
      password_hash => postgresql_password('vagrant', 'lacet'),
      createdb      => true,
      login         => true,
    }
      
    postgresql::database_grant{'vagrant':
      privilege =>  ALL,
      db => 'shoe',
      role => 'vagrant',
    }
    $packages = [ 'git', 'ruby', 'apache2','www-apache/mod_ruby',  'ruby-pg','ruby-dbi']
    $apache_user = 'www-data'
    $apache_config = '/etc/apache2/sites-available/default'
  } else {
    $packages = [ 'git', 'ruby', 'www-servers/apache','www-apache/mod_ruby', 'dev-ruby/dbi', 'dev-ruby/postgres' ]
    $apache_user = 'apache'
    $apache_config = "/etc/apache2/vhosts.d/shoe"
  }
  $gems     = [ 'sbsm', 'htmlgrid', 'odba', 'rmail', 'hpricot' ]
  
  package{$packages: ensure => installed }
  $vcsRoot = '/var/www/shoe'
  
  package{$gems:
    provider => 'gem',
    }

  file { "$apache_config":
    content => template("shoe/shoe.conf"),
    require => Package[$packages],
  }

  vcsrepo {  "$vcsRoot":
      ensure => present,
      provider => git,
      owner => $apache_user,
      group => $apache_user,
      source => "https://github.com/zdavatz/shoe",
      require => [Package[$packages], ],
  }
    
  
}
