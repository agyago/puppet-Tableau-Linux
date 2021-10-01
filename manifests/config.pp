# Tableau configuration module

define tableau::config (
  String $version  = undef,
  Array  $admin    = undef
){
    $ad_user       = lookup('tableau::ad_user')
    $ad_pswd       = lookup('tableau::ad_paswd')
    $ad_host       = lookup('tableau::ad_host')
    $boot_file_stg = lookup('tableau::boot_file_stg')
    $boot_file_prd = lookup('tableau::boot_file_prd')
    $boot_file_stndby = lookup('tableau::boot_file_stndby')
    $proxypath     = '/var/opt/tableau/tableau_server/.config/systemd/tableau_server.conf.d'
    file {
      '/tmp/reg.json':
        ensure => file,
        mode   => '0600',
        source => 'puppet:///modules/tableau/reg.json';

      '/tmp/AD.json':
        ensure  => file,
        mode    => '0600',
        content => template('tableau/AD.json.erb');

      '/tmp/bootstrap-tbl.json':
        ensure  => file,
        mode    => '0644',
        content => template('tableau/bootstrap-tbl.json.erb');

      "${proxypath}/20-proxy.conf":
        ensure  => file,
        owner   => tableau,
        group   => tableau,
        require => Exec['init'],
        content => template('tableau/20-proxy.conf.erb');
  }
  $settings = {
    'version'       =>  $version,
    'register'      =>  '/tmp/reg.json',
    'identity'      =>  '/tmp/AD.json',
    'initadmin'     =>  lookup('tableau::initadmin'),
    'initpaswd'     =>  lookup('tableau::initpaswd'),
  }
  exec { 'init':
    command   => epp('tableau/initial.epp',$settings),
    require   => Package['tableau-server-20211.21.0819.1914-20211-21.0819.1914.x86_64'],
    logoutput => on_failure,
    unless    => '/usr/bin/grep -c tableau /etc/passwd'
  }
  if $facts['fqdn'] =~ /srv/ {
    exec { 'source':
      command => "/bin/bash -c 'source /etc/profile.d/tableau_server.sh'",
      path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
      onlyif  => 'test ! -f /opt/tableau/tableau_user',
    }
    ~> exec { 'Activate':
      command     => epp('tableau/activate.epp',$settings),
      logoutput   => on_failure,
      refreshonly => true,
    }
    ~> exec { 'Register':
      command     => epp('tableau/register.epp',$settings),
      logoutput   => on_failure,
      refreshonly => true
    }
    ~> exec { 'Configure node1':
    command     => epp('tableau/confignode1.epp',$settings),
    logoutput   => on_failure,
    refreshonly => true
  }
  ~> exec { 'Apply and start':
    command     => epp('tableau/applyandstart.epp',$settings),
    logoutput   => on_failure,
    timeout     => 2000,
    refreshonly => true
  }
  ~> exec { 'Create initial server admin':
    command     => epp('tableau/initadmin.epp',$settings),
    logoutput   => on_failure,
    refreshonly => true
  }
  }
  file {'/opt/tableau/tableau_user':
    ensure  => file,
    content => template('tableau/tableau_user.erb'),
    alias   => 'tableau_user',
  }
  exec {'add tsm admin':
    command     => 'for x in $(cat /opt/tableau/tableau_user);do /sbin/usermod -a -G tsmadmin $x;done',
    provider    => shell,
    subscribe   => File['tableau_user'],
    refreshonly => true,
  }
}
