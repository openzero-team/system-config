# == Class: cibook_project::jenkins_config
#
class cibook_project::jenkins_config (
  $jenkins_username        = 'jenkins',
  $jenkins_password        = undef,
  $jenkins_url             = undef,
  $jenkins_ssh_private_key = undef,
  $jenkins_credential      = undef,

) {

  $tmp_folder             = '/opt/jenkins'
  $change_password_file   = "$tmp_folder/change_password.sh"
  $create_credential_file = "$tmp_folder/create_credential.py"

  file { $tmp_folder:
    ensure   => directory,
    mode     => '0755',
    owner    => 'jenkins',
    group    => 'jenkins',
  }

  file { $change_password_file:
    mode     => "0644",
    owner    => 'jenkins',
    group    => 'jenkins',
    source   => 'puppet:///modules/cibook_project/jenkins/change_password.sh',
    require  => File[$tmp_folder]
  }

  exec {'change jenkins username':
    command  => "mv /var/lib/jenkins/users/admin /var/lib/jenkins/users/$jenkins_username",
    user     => root,
    onlyif   => "test -d /var/lib/jenkins/users/admin",
    path     => '/usr/bin:/usr/sbin:/bin:/sbin',
    require  => File[$create_credential_file],
  }

  exec { 'change jenkins password':
    command  => "bash $change_password_file $jenkins_username $jenkins_password",
    path     => '/usr/local/bin:/usr/bin:/bin/',
    require  => File[$change_password_file]
  }

  jenkins::plugin { 'credentials':
    version => '2.1.16',
    before  => Exec['restart jenkins'],
  }

  jenkins::plugin { 'structs':
    version => '1.10',
    before => Exec['restart jenkins'],
  }

  jenkins::plugin { 'ssh-credentials':
    version => '1.13',
    before => Exec['restart jenkins'],
  }

  exec { 'restart jenkins':
    command  => "service jenkins restart",
    path     => '/usr/local/bin:/usr/bin:/bin/',
    require  => Exec["change jenkins password"]
  }


  file { $create_credential_file:
    mode     => "0644",
    owner    => 'jenkins',
    group    => 'jenkins',
    source   => 'puppet:///modules/cibook_project/jenkins/create_credentials.py',
    require  => File["$tmp_folder"]
  }

  exec { 'create credentials':
    command  => "
      sleep 30
      python $create_credential_file -l $jenkins_url -u $jenkins_username \
             -p $jenkins_password -i $jenkins_credential -c $jenkins_username \
             -k \"$jenkins_ssh_private_key\"
      ",
    provider => shell,
    path     => '/usr/local/bin:/usr/bin:/bin/',
    require  => [File[$create_credential_file], Exec['restart jenkins']],
  }
}
