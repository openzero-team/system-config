# == Class: openstackci::nodepool
#
class cibook_project::nodepool_node (
  $vhost_name                    = $::fqdn,
  $project_config_repo           = undef,

  $jenkins_username              = 'cibook',
  $jenkins_ssh_public_key        = undef,
  $jenkins_ssh_private_key       = undef,
  # Nodepool configurations
  $oscc_file_contents            = undef,
  $mysql_host                    = undef,
  $mysql_db_name                 = "nodepool"
  $mysql_root_password           = undef,
  $mysql_nodepool_password       = undef,
  $nodepool_jenkins_target       = undef,
  $jenkins_api_key               = undef,
  $jenkins_credentials_id        = undef,
  $nodepool_revision             = 'master',
  $nodepool_git_source_repo      = 'https://git.openstack.org/openstack-infra/nodepool',
  $jenkins_url                   = 'http://localhost:8080/',
) {


  class { '::openstackci::nodepool':
    mysql_host                => $mysql_host,
    mysql_db_name            => $mysql_db_name,
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_nodepool_password,
    nodepool_ssh_private_key  => $jenkins_ssh_private_key,
    revision                  => $nodepool_revision,
    git_source_repo           => $nodepool_git_source_repo,
    oscc_file_contents        => $oscc_file_contents,
    environment               => {
      # Set up the key in /etc/default/nodepool, used by the service.
      'NODEPOOL_SSH_KEY' => $jenkins_ssh_public_key
    },
    project_config_repo       => $project_config_repo,
    # Disable nodepool image logs as it conflicts with the zuul status page
    enable_image_log_via_http => false,
    install_mysql             => false,
    jenkins_masters           => [
      { name        => $nodepool_jenkins_target,
        url         => $jenkins_url,
        user        => $jenkins_username,
        apikey      => $jenkins_api_key,
        credentials => $jenkins_credentials_id,
      },
    ],
  }

  service { 'open-iscsi':
    ensure => stopped,
    enable => false,
  }

}
