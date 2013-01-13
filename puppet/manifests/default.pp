$user = 'vagrant'
$home = '/home/vagrant'

# Make sure apt-get -y update runs before anything else.
stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { '/usr/bin/apt-get -y update':
    user => 'root'
  }
}

class { 'apt_get_update':
  stage => preinstall
}

class install_sqlite3 {
  package { 'sqlite3':
    ensure => installed;
  }

  package { 'libsqlite3-dev':
    ensure => installed;
  }
}
class { 'install_sqlite3': }

class install_mysql {
  class { 'mysql': }

  class { 'mysql::server':
    config_hash => { 'root_password' => '' }
  }

  package { 'libmysqlclient15-dev':
    ensure => installed
  }
}
class { 'install_mysql': }

class install_postgres {
  class { 'postgresql': }

  class { 'postgresql::server': }

  pg_user { 'vagrant':
    ensure    => present,
    superuser => true,
    password  => 'vagrant',
    require   => Class['postgresql::server']
  }

  package { 'libpq-dev':
    ensure => installed
  }
}
class { 'install_postgres': }

class install_core_packages {
  package { ['build-essential', 'vim', 'ruby1.9.3']:
    ensure => installed
  }
}
class { 'install_core_packages': }

class install_nokogiri_dependencies {
  package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
    ensure => installed
  }
}
class { 'install_nokogiri_dependencies': }

class install_rbenv {
  rbenv::install { 'vagrant':
    group => $user,
    home => $home
  }

  rbenv::compile { '1.9.3-p362':
    user => $user,
    home => $home
  }
}
class { 'install_rbenv': }

class setup_env {
  exec { "cd /tmp && git clone git://github.com/brennovich/dotfiles.git && cd /tmp/dotfiles && chmod +x install.sh && ./install.sh":
    user => $user,
    path => "${home}/bin:${home}/.rbenv/shims:/bin:/usr/bin"
  }
}
class { 'setup_env': }

class { 'nodejs':
  version => '0.8.17',
}

class { 'memcached': }
