node "common-gearman.openstacklocal" {
    class { 'gearman': }
}

node "gerrit" {
  package { 'ssl-cert':
    ensure => present,
  }

  exec { 'ensure ssl-cert exists':
    command => '/usr/sbin/groupadd -f ssl-cert'
  }

  # workaround since pip is not being installed as part of this module
  package { 'python-pip':
    ensure => present,
  }

  class { 'gerrit::mysql':
    mysql_root_password => 'UNSET',
    database_name       => 'reviewdb',
    database_user       => 'gerrit2',
    database_password   => '12345',
  }

  class { 'gerrit':
    manage_jeepyb                       => false,
    mysql_host                          => 'localhost',
    mysql_password                      => '12345',
    war                                 => 'http://tarballs.openstack.org/ci/gerrit/gerrit-v2.9.4.5.73392ca.war',
  }
}

node 'jenkins' {

  $vhost_name = hiera('vhost_name_jenkins', $::fqdn)

  class { '::openstackci::jenkins_node':
    vhost_name                  => $vhost_name,
    project_config_repo         => hiera('project_config_repo'),
    serveradmin                 => hiera('serveradmin', "webmaster@${vhost_name}"),
    jenkins_version             => hiera('jenkins_version', 'present'),
    jenkins_vhost_name          => hiera('jenkins_vhost_name', 'jenkins'),
    jenkins_username            => hiera('jenkins_username', 'jenkins'),
    jenkins_password            => hiera('jenkins_password', 'XXX'),
    jenkins_ssh_private_key     => hiera('jenkins_ssh_private_key'),
    jenkins_ssh_public_key      => hiera('jenkins_ssh_public_key'),
    log_server                  => hiera('log_server'),
    jjb_git_revision            => hiera('jjb_git_revision', '1.6.2'),
    jjb_git_url                 => hiera('jjb_git_url',
      'https://git.openstack.org/openstack-infra/jenkins-job-builder'),
    java_args_override          => hiera('java_args_override', '-Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Shanghai')
  }

}