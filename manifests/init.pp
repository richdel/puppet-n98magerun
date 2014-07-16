class n98magerun(
  $php_package = 'php5-cli',
  $install_dir = '/usr/local/bin',
  $stable      = true,
  $config_file = false
) {
  include augeas

  if $stable {
    $download_path = 'https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar'    
  } else {
    $download_path = 'https://raw.githubusercontent.com/netz98/n98-magerun/develop/n98-magerun.phar'    
  }
   
  exec { 'download n98-magerun':
    command     => "curl -L -o n98-magerun.phar ${download_path}",
    creates     => "${install_dir}/n98-magerun.phar",
    cwd         => $install_dir,
    require     => [
      Package['curl', $php_package],
      Augeas['allow_url_fopen']
    ]
  }

  file { 'n98-magerun.phar':
    path    => "${install_dir}/n98-magerun.phar",
    mode    => '0755',
    owner   => root,
    group   => root,
    require => Exec['download n98-magerun']
  }

  if $config_file {
    file { '.n98-magerun.yaml':
      path => "${install_dir}/.n98-magerun.yaml",
      ensure => present,
      source => "${config_file}",
      ownder => root,
      group => root
    }
  }

  augeas{ 'allow_url_fopen':
    context => '/files/etc/php5/cli/php.ini/PHP',
    changes => 'set allow_url_fopen On',
    require => Package[$php_package]
  }
}
