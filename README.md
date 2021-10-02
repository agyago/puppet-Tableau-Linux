# Tableau-Linux

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with [modulename]](#setup)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)


## Description

  Although Tableau gave a simple one-liner auto install, it is better to puppetize it for easier deployment. 
  This module will install server and worker nodes.


## Setup

    install.pp:
    /opt/tableau/tableau_driver/jdbc => input your repo source
    ensure_packages sources          => input your repo source
    archive (optional)               => inout your source (this could be deleted)

    On tblcert.pp:
    $tableau_path  = '/opt/tableau/tableau_server/packages/customer-bin.20211.21.0819.1914' # change this to your version

    On Config.pp
    exec init 
    require   => Package['tableau-server-20211.21.0819.1914-20211-21.0819.1914.x86_64'], # change this to the tablea version package

    Data/secrets.yaml => change input the required credentials

    files/reg.json => input the required json file for tableau registration

    templates/AD.json.erb => input the required details in your AD/LDAP
    templates/creds.epp => input your domain
    templates/20-proxy.conf.erb => fill this with your main server and workers and your proxy server
    
    1. Install node1 first using the server.pp
    2. Once installed, go to the tsm web and download the bootstrap
    3. login to the puppetserver or compiler and encrypt it
    example:
    # String (encrypting usernames)
      /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -s "string"
    # Password (will get prompted to enter a string --encrypting passwords)
      /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -p
    # Files (encrypting keys)
      /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -f $file
    4. copy the file and paste it into Data/secrets.yaml -> tableau::boot_file_
    5. install worker node via worker.pp
    6. puppet run on each node. hint: (use jobs)
  
               


### Setup Requirements **OPTIONAL**

'puppet-archive',                '5.0.0'



## Usage
```
server.pp || worker.pp
tableau::config { 'server': # or worker
    version => '20211.21.0819.1914', # place the version here
    admin   => ['user1','user2']     # users who need access to tsmadmin
  }
```



