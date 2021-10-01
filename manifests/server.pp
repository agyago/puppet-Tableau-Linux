# tableau initialize and configure 1st node

class tableau::server {
  contain tableau::install
  contain tableau::tblcert

  tableau::config { 'server':
    version => '20211.21.0819.1914',
    admin   => ['user1','user2']
  }
    $cred = {
    'users' => lookup('tableau::users'),
    'paswd' => lookup('tableau::paswd'),
  }
  file {
    '/mnt/tableau_backup':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0775';
    '/tmp/credsfile':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0600',
      content => epp('tableau/credsfile.epp',$cred);
  }
  mount {
    '/mnt/tableau_backup':
      ensure  => mounted,
      atboot  => true,
      device  => 'yourdevice', #your device
      options => 'vers=3.0,credentials=/tmp/credsfile,rw',
      fstype  => 'cifs', # or nfs
      require => File['/mnt/tableau_backup']
  }
}
