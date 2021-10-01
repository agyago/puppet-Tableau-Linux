# tableau worker nodes initialize

class tableau::worker {
  contain tableau::install

  tableau::config { 'worker':
    version => '20211.21.0819.1914',
    admin   => ['user1','user2']
  }

}
