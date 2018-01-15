node 'gearman.cibook.oz' {
    class { 'gearman': }
}

node 'zookeeper.cibook.oz' {
  $vhost_name = hiera('vhost_name_common', $::fqdn)

  class { '::cibook_project::common_nodepool_db':
    vhost_name              => $vhost_name,
    mysql_bind_address      => hiera('mysql_bind_address'),
    mysql_root_password     => hiera('mysql_root_password'),
    mysql_nodepool_password => hiera('mysql_nodepool_password'),
  }

  # aviod the nodepoll and gerrit mysql db declaration conflict, delete the gerrit db temporarily.
  # class { '::cibook_project::common_gerrit_db':
  #   mysql_root_password => hiera('mysql_gerrit_root_password'),
  #   database_name       => hiera('mysql_gerrit_name'),
  #   database_user       => hiera('mysql_gerrit_user'),
  #   database_password   => hiera('mysql_gerrit_password'),
  # }

  class { 'zookeeper':
    install_java => true,
    java_package => 'openjdk-7-jre-headless',
  }

}

node 'gerrit.cibook.oz' {

  $vhost_name = hiera('vhost_name_gerrit', $::fqdn)

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

  class { 'gerrit':
    mysql_host                  => hiera('vhost_name_mysql'),
    mysql_password              => hiera('mysql_gerrit_password'),
    vhost_name                  => $vhost_name,
    redirect_to_canonicalweburl => false,
    canonicalweburl             => "https://${vhost_name}",
    war                         => 'http://tarballs.openstack.org/ci/gerrit/gerrit-v2.9.4.5.73392ca.war',
    gerrit_auth_type            => 'DEVELOPMENT_BECOME_ANY_ACCOUNT',
    manage_jeepyb               => false,
  }
}

node 'jenkins.cibook.oz' {

  $vhost_name = hiera('vhost_name_jenkins', $::fqdn)

  class { '::openstackci::jenkins_node':
    vhost_name              => $vhost_name,
    project_config_repo     => hiera('project_config_repo'),
    serveradmin             => hiera('serveradmin', "webmaster@${vhost_name}"),
    jenkins_version         => hiera('jenkins_version', 'present'),
    jenkins_vhost_name      => hiera('jenkins_vhost_name', 'jenkins'),
    jenkins_username        => hiera('jenkins_username', 'jenkins'),
    jenkins_password        => hiera('jenkins_password', 'XXX'),
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key'),
    jenkins_ssh_public_key  => hiera('jenkins_ssh_public_key'),
    log_server              => hiera('log_server'),
    jjb_git_revision        => hiera('jjb_git_revision', '1.6.2'),
    jjb_git_url             => hiera('jjb_git_url',
      'https://git.openstack.org/openstack-infra/jenkins-job-builder'),
    java_args_override      => hiera('java_args_override', '-Dhudson.model.ParametersAction.keepUndefinedParameters=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Shanghai') # lint:ignore:140chars
  }

}

node 'log.cibook.oz' {
  class { '::openstackci::logserver':
    domain                  => hiera('domain'),
    jenkins_ssh_key         => hiera('jenkins_ssh_public_key'),
    swift_authurl           => hiera('swift_authurl', ''),
    swift_user              => hiera('swift_user', ''),
    swift_key               => hiera('swift_key', ''),
    swift_tenant_name       => hiera('swift_tenant_name', ''),
    swift_region_name       => hiera('swift_region_name', ''),
    swift_default_container => hiera('swift_default_container', ''),
  }
}

node 'zuul.cibook.oz' {
  $vhost_name = hiera('vhost_name_zuul', $::fqdn)

  class { '::cibook_project::zuul_node':
    vhost_name                  => $vhost_name,
    project_config_repo         => hiera('project_config_repo'),
    gearman_server              => hiera('gearman_server'),
    gerrit_server               => hiera('gerrit_server'),
    gerrit_user                 => hiera('gerrit_user'),
    gerrit_user_http_passwd     => hiera('gerrit_user_http_passwd'),
    gerrit_user_ssh_public_key  => hiera('gerrit_user_ssh_public_key'),
    gerrit_user_ssh_private_key => hiera('gerrit_user_ssh_private_key'),
    gerrit_ssh_host_key         => hiera('gerrit_ssh_host_key'),
    git_email                   => hiera('git_email'),
    git_name                    => hiera('git_name'),
    log_server                  => hiera('log_server'),
    log_server_public           => hiera('log_server_public'),
    smtp_host                   => hiera('smtp_host', 'localhost'),
    smtp_default_from           => hiera('smtp_default_from', "zuul@${vhost_name}"),
    smtp_default_to             => hiera('smtp_default_to', "zuul.reports@${vhost_name}"),
    zuul_revision               => hiera('zuul_revision', 'master'),
    zuul_git_source_repo        => hiera('zuul_git_source_repo'),
  }
}

node 'nodepool.cibook.oz' {

    # If the fqdn is not resolvable, use its ip address
  $vhost_name = hiera('vhost_name_nodepool', $::fqdn)

  class { '::cibook_project::nodepool_node':
    vhost_name               => $vhost_name,
    project_config_repo      => hiera('project_config_repo'),
    jenkins_username         => hiera('jenkins_username', 'jenkins'),
    jenkins_ssh_public_key   => hiera('jenkins_ssh_public_key'),
    jenkins_ssh_private_key  => hiera('jenkins_ssh_private_key'),
    oscc_file_contents       => hiera('oscc_file_contents', ''),
    mysql_host               => hiera('vhost_name_mysql'),
    mysql_root_password      => hiera('mysql_root_password'),
    mysql_db_name            => hiera('mysql_nodepool_db_name', 'nodepool'),
    mysql_nodepool_password  => hiera('mysql_nodepool_password'),
    nodepool_jenkins_target  => hiera('nodepool_jenkins_target', 'jenkins-cibook'),
    jenkins_api_key          => hiera('jenkins_api_key', 'XXX'),
    jenkins_credentials_id   => hiera('jenkins_credentials_id', 'XXX'),
    jenkins_url              => hiera('jenkins_url', 'http://jenkins.cibook.oz:8080'),
    nodepool_revision        => hiera('nodepool_revision', 'master'),
    nodepool_git_source_repo => hiera('nodepool_git_source_repo',
      'http://opnfv.zte.com.cn/gerrit/openstack/nodepool'),
  }

}


node 'elk.cibook.oz' {

  $elasticsearch_nodes = [ hiera('vhost_name_elk') ]

  class { 'cibook_project::logstash':
    discover_nodes      => [ "hiera('vhost_name_elk'):9200" ]
  }

  class { 'cibook_project::logstash_worker':
    discover_node         => hiera('vhost_name_elk'),
    enable_mqtt           => false,
    mqtt_hostname         => hiera('vhost_name_elk'),
    mqtt_password         => '',
    mqtt_ca_cert_contents => '',
  }

  class { 'cibook_project::elasticsearch_node':
    discover_nodes => $elasticsearch_nodes
  }
}
