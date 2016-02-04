# Configure attributes for Java install.
# See https://github.com/agileorbit-cookbooks/java.

# WiP: Moved all attributes to recipe level to attempt to debug Java version issue.
# https://github.com/chef-cookbooks/tomcat/issues/198

# node.default['java']['jdk_version'] = "7"
# node.default['java']['java_home'] = "/usr/lib/jvm/java"
# node.default['java']['install_flavor'] = "oracle"
# node.default['java']['oracle']['accept_oracle_download_terms'] = true


# default['java']['jdk']['7']['x86_64']['url'] = 'http://artifactory.example.com/artifacts/jdk-7u65-linux-x64.tar.gz'