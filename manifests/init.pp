# class: stickler
class stickler (
  $version  = 'present',
  $path     = '/var/lib/stickler',
  $upstream = 'https://rubygems.org',
  $port     = '6789',
  $firewall = true
) {

  require 'stickler::package'

  ensure_resource( 'file', '/root/.gem',
    { 'ensure' => 'directory' }
  )

  file { '/root/.gem/stickler':
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => template('stickler/stickler.erb'),
  }

  include '::apache'
  include '::passenger'
  include '::ruby::dev'

  exec { 'config_stickler':
    command => "stickler-passenger-config apache2 ${path}",
    creates => $path,
    path    => $::path,
  } ->

  file { [
    $path,
    "${path}/config.ru",
    "${path}/public",
    "${path}/tmp",
  ]:
    owner => 'apache',
    group => 'apache',
  } ->

  # This is still needed to for multi gem uploads.
  # apache passenger doesn't work with excon gem in testing.
  service { 'stickler':
    ensure    => running,
    start     => "stickler-server start --daemonize ${path}",
    stop      => "stickler-server stop ${path}",
    hasstatus => false,
    require   => Package['stickler'],
  }

  apache::vhost { 'stickler':
    ensure             => present,
    servername         => 'gem',
    port               => 80,
    docroot            => "${path}/public",
    configure_firewall => $firewall,
  }
}
