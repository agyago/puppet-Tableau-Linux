# tableau SSL

class tableau::tblcert {
  $svc = 'tableau'
  $ssl_name = 'yourcertname' #certname
  $ssl_cert_file = "/etc/${svc}/${ssl_name}.cert"
  $ssl_cert_chain = "/etc/${svc}/${ssl_name}.chain"
  $ssl_key_file = "/etc/${svc}/${ssl_name}.key"

  class {'itsys_tools::ssl_manager':
    ssl_rpath => $svc,
    ssl_file  => $ssl_name,
    ssl_user  => 'root',
    ssl_group => 'root',
    ssl_cert  => lookup('tableau::tbl_cert'),
    ssl_chain => lookup('tableau::tbl_chain'),
    ssl_key   => lookup('tableau::tbl_key'),
  }
  $tableau_path  = '/opt/tableau/tableau_server/packages/customer-bin.20211.21.0819.1914'
  exec { 'Cert Enable': # This is to apply only the cert, Tableau still needs to be restarted 
    command     => "${tableau_path}/tsm security external-ssl enable --cert-file ${ssl_cert_file} --key-file ${ssl_key_file} --chain-file ${ssl_cert_chain}",
    #require     => Exec['Create initial server admin'],
    subscribe   => File["/etc/${svc}/${ssl_name}.cert"],
    timeout     => 2000,
    refreshonly => true
  }
}
