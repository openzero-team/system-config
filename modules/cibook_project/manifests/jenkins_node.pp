# == Class: cibook_project::jenkins_node
#
class cibook_project::jenkins_node (
  $vhost_name                    = $::fqdn,
  $project_config_repo           = undef,

  # Jenkins Configurations
  $jenkins_vhost_name            = 'jenkins',
  $serveradmin                   = "webmaster@${vhost_name}",
  $jenkins_username              = 'jenkins',
  $jenkins_password              = undef,
  $jenkins_ssh_private_key       = undef,
  $jenkins_ssh_public_key        = undef,
  $java_args_override            = undef,
  $jenkins_version               = 'present',
  $jjb_git_revision              = 'master',
  $jjb_git_url                   = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $log_server                    = undef,
  $java_args_override            = undef,
  $jenkins_credential            = undef,

) {

  stage { 'post_install': }

  Stage['main'] -> Stage['post_install']

  class { '::openstackci::jenkins_master':
    vhost_name              => $jenkins_vhost_name,
    serveradmin             => $serveradmin,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $jenkins_ssh_public_key,
    jenkins_version         => $jenkins_version,
    manage_jenkins_jobs     => true,
    jenkins_url             => "http://${vhost_name}:8080/",
    jenkins_username        => $jenkins_username,
    jenkins_password        => $jenkins_password,
    project_config_repo     => $project_config_repo,
    log_server              => $log_server,
    java_args_override      => $java_args_override,
    jjb_git_revision        => $jjb_git_revision,
    jjb_git_url             => $jjb_git_url,
  }

  service { 'open-iscsi':
    ensure => stopped,
    enable => false,
  }

  class { '::cibook_project::jenkins_config':
    jenkins_username        => $jenkins_username,
    jenkins_password        => $jenkins_password,
    jenkins_url             => "http://${vhost_name}:8080/",
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_credential      => $jenkins_credential,

    stage => 'post_install',
  }
}

