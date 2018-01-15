# == Class: openstackci::zuul_node
#
class cibook_project::zuul_node (
  $vhost_name                    = $::fqdn,
  $project_config_repo           = undef,

  # Zuul Configurations
  $gerrit_server                 = 'review.openstack.org',
  $gerrit_user                   = undef,
  $gerrit_user_http_passwd       = undef,
  $gerrit_user_ssh_public_key    = undef,
  $gerrit_user_ssh_private_key   = undef,
  $gerrit_ssh_host_key           = '',
  $gearman_server                = 'localhost',
  $git_email                     = undef,
  $git_name                      = undef,
  $log_server                    = undef,
  $log_server_public             = undef,
  $smtp_host                     = 'localhost',
  $smtp_default_from             = "zuul@${vhost_name}",
  $smtp_default_to               = "zuul.reports@${vhost_name}",
  $zuul_revision                 = 'master',
  $zuul_git_source_repo          = 'http://opnfv.zte.com.cn/gerrit/openstack/zuul',
  $zuul_port                     = '80',
) {

  class { '::openstackci::zuul_merger':
    vhost_name           => $vhost_name,
    gearman_server       => $gearman_server,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    # known_hosts_content is set by openstackci::zuul_scheduler
    known_hosts_content  => '',
    zuul_ssh_private_key => $gerrit_user_ssh_private_key,
    zuul_url             => "http://${vhost_name}:${zuul_port}/p/",
    git_email            => $git_email,
    git_name             => $git_name,
    manage_common_zuul   => false,
    revision             => $zuul_revision,
    git_source_repo      => $zuul_git_source_repo,
  }

  class { '::openstackci::zuul_scheduler':
    vhost_name           => $vhost_name,
    gearman_server       => $gearman_server,
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    known_hosts_content  => $gerrit_ssh_host_key,
    zuul_ssh_private_key => $gerrit_user_ssh_private_key,
    url_pattern          => "http://${log_server_public}/{build.parameters[LOG_PATH]}",
    zuul_url             => "http://${vhost_name}:${zuul_port}/p/",
    job_name_in_report   => true,
    status_url           => "http://${vhost_name}",
    project_config_repo  => $project_config_repo,
    git_email            => $git_email,
    git_name             => $git_name,
    smtp_host            => $smtp_host,
    smtp_default_from    => $smtp_default_from,
    smtp_default_to      => $smtp_default_to,
    revision             => $zuul_revision,
    git_source_repo      => $zuul_git_source_repo,
  }

  service { 'open-iscsi':
    ensure => stopped,
    enable => false,
  }

}
