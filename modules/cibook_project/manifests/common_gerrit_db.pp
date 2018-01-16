
# == Class: cibook_project::common_gerrit_node

class cibook_project::common_gerrit_db (
  $mysql_root_password  = undef,
  # gerrit db config
  $database_name        = 'reviewdb',
  $database_user        = 'gerrit2',
  $database_password    = undef,

) {

class { '::gerrit::mysql' :
    mysql_root_password => $mysql_root_password,
    database_name       => $database_name,
    database_user       => $database_user,
    database_password   => $database_password,
  }
}
