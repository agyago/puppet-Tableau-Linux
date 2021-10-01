# tableau install packages and drivers

class tableau::install {
  file {
    '/etc/yum.repos.d/mysql-community.repo':
      source => 'puppet:///modules/tableau/repo/mysql-community.repo',
      owner  => root,
      group  => root,
      mode   => '0664';
    '/opt/tableau/tableau_driver/jdbc':
      ensure => 'directory';
    '/opt/tableau/tableau_driver/jdbc/postgresql-42.2.14.jar':
      source => 'src/Binaries/Tableau/postgresql-42.2.14.jar',
      owner  => root,
      group  => root,
      mode   => '0644';
  }
  ensure_packages(['gdb','chrpath','freeglut','bash-completion','mysql-connector-odbc','unixODBC-devel','google-noto-cjk-fonts'])
  ensure_packages(
    {
      'tableau-server-20211.21.0819.1914-20211-21.0819.1914.x86_64' =>
        {
          source => 'src/Tableau/tableau-server-2021-1-5.x86_64.rpm',
          provider => rpm
        },
      'SimbaPrestoODBC-64bit.x86_64' =>
        {
          source   => 'src/Tableau/simbapresto-1.1-x86_64.rpm',
          provider => rpm
        },
      'tableau-postgresql-odbc.x86_64' =>
        {
          source   => 'src/Tableau/tableau-postgresql-odbc-09.06.0500-1.x86_64.rpm',
          provider => rpm
        },
      'vertica-client.x86_64' =>
        {
          source   => 'src/Tableau/vertica-client-9.3.1-0.x86_64.rpm',
          provider => rpm
        }
    }, {'ensure' => 'present'} )
  file { '/etc/odbcinst.ini':
    source => 'puppet:///modules/tableau/odbcinst.ini',
    owner  => root,
    group  => root,
    mode   => '0644',
  }
  archive {
    'Chirp_Roman.zip':
      path         => '/tmp/Chirp_Roman.zip',
      source       => 'src/Tableau/Chirp_Roman.zip',
      extract      => true,
      extract_path => '/usr/share/fonts/',
      creates      => '/usr/share/fonts/Chirp_Roman.zip';
    'ChirpTPJ.zip':
      path         => '/tmp/ChirpTPJ.zip',
      source       => 'src/Tableau/ChirpTPJ.zip',
      extract      => true,
      extract_path => '/usr/share/fonts/',
      creates      => '/usr/share/fonts/ChirpTPJ.zip';
  }
  exec { 'refresh fonts':
    command     => 'fc-cache -f -v',
    provider    => shell,
    subscribe   => Archive['Chirp_Roman.zip','ChirpTPJ.zip'],
    refreshonly => true,
  }
}
