# Configure attributes for Tomcat install.
# See https://github.com/chef-cookbooks/tomcat

# WiP: Moved all attributes to recipe level to attempt to debug Java version issue.
# https://github.com/chef-cookbooks/tomcat/issues/198

node.default['tomcat']['base_version'] = '7'
node.default['tomcat']['port'] = 7000
node.default['tomcat']['ssl_port'] = 8443
node.default['tomcat']['java_options'] = "${JAVA_OPTS} -Xmx128M -Djava.awt.headless=true"

if node['cloud'] == true
  node.default['tomcat']['catalina_options'] = "-Dspring.profiles.active=prod -Darchaius.deployment.applicationId=genie -Dnetflix.datacenter=cloud -Darchaius.deployment.environment=prod"
else
  node.default['tomcat']['catalina_options'] = "-Dspring.profiles.active=prod -Darchaius.deployment.applicationId=genie -Darchaius.deployment.environment=prod"
end