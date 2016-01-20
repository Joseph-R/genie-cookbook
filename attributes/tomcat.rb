# Configure attributes for Tomcat install.
# See https://github.com/chef-cookbooks/tomcat

node.default['tomcat']['base_version'] = '7'
node.default['genie']['tomcat']['port'] = "8080"
node.default['genie']['tomcat']['ssl_port'] = "8443"