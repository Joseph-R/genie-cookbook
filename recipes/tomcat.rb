# Install Tomcat as part of the setup for Genie - https://github.com/Netflix/genie/wiki/Setup
# See https://github.com/chef-cookbooks/tomcat for use and example code.

# node.default['catalina']['home'] = "#{node['hadoop']['home']}/apache-tomcat-#{node['tomcat']['version']}"

# Set ENV variables for the Chef shell and any child processes spawned by this recipe.
#@todo - Deprecate.  https://github.com/chef-cookbooks/tomcat/pull/171
## ENV['TOMCAT_VERSION'] = node['genie']['tomcat']['base_version']
## ENV['CATALINA_HOME'] = node['catalina']['home']
## ENV['JAVA_HOME'] = node['java']['java_home']
## ENV['CATALINA_OPTS'] = "-Darchaius.deployment.applicationId=genie -Dnetflix.datacenter=cloud"

# Hack until https://github.com/chef-cookbooks/tomcat/issues/148 gets resolved...
### Changed value(s):
node.default['tomcat']['base_version'] = '7'

### Unchanged values that rely on above being different:
suffix = node['tomcat']['base_version'].to_i < 7 ? node['tomcat']['base_version'] : ''
node.default['tomcat']['base_instance'] = "tomcat#{suffix}"
node.default['tomcat']['home'] = "/usr/share/tomcat#{suffix}"
node.default['tomcat']['base'] = "/usr/share/tomcat#{suffix}"
node.default['tomcat']['config_dir'] = "/etc/tomcat#{suffix}"
node.default['tomcat']['log_dir'] = "/var/log/tomcat#{suffix}"
node.default['tomcat']['tmp_dir'] = "/var/cache/tomcat#{suffix}/temp"
node.default['tomcat']['work_dir'] = "/var/cache/tomcat#{suffix}/work"
node.default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
node.default['tomcat']['webapp_dir'] = "/var/lib/tomcat#{suffix}/webapps"
node.default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
node.default['tomcat']['endorsed_dir'] = "#{node['tomcat']['lib_dir']}/endorsed"
node.default['tomcat']['packages'] = ["tomcat#{suffix}"]
node.default['tomcat']['deploy_manager_packages'] = ["tomcat#{suffix}-admin-webapps"]

# Install and configure Tomcat with cookbook attributes.
include_recipe "tomcat::default"