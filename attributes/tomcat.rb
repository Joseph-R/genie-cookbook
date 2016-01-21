# Configure attributes for Tomcat install.
# See https://github.com/chef-cookbooks/tomcat

node.default['tomcat']['base_version'] = '7'
node.default['tomcat']['port'] = 7000
node.default['tomcat']['ssl_port'] = 8443

node.default['tomcat']['catalina_options'] = "-Dspring.profiles.active=prod -Darchaius.deployment.applicationId=genie -Dnetflix.datacenter=cloud -Darchaius.deployment.environment=prod"
# node.default['tomcat']['java_options'] = 