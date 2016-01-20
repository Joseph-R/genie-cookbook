require 'spec_helper'

# Verify that Tomcat service is installed and running.
# For Genie-specific configs, see genie_spec.rb

service_name = 'tomcat'
package_name = 'tomcat'
config_dir = '/etc/tomcat'

describe package(package_name) do
  it { should be_installed }
end

describe service(service_name) do
  it { should be_enabled }
  it { should be_running }
end