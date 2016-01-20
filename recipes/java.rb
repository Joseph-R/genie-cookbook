# Install Java using the community cookbook.
# Uses the Oracle JDK for Java 7, recommended by https://github.com/Netflix/genie/wiki/Setup.

node.default['java']['jdk_version'] = "7"
node.default['java']['install_flavor'] = "oracle"
node.default['java']['oracle']['accept_oracle_download_terms'] = true
#node.default['java']['accept_license_agreement'] = true
node.default['java']['set_default'] = true
node.default['java']['java_home'] = "/usr/lib/jvm/java"

# Install and configure Java with cookbook attributes.
include_recipe "java::default"

# See https://github.com/agileorbit-cookbooks/java for use and example code.