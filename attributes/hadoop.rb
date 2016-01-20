# Set hadoop attributes
# Default assumes HDP distribution.  Can be overwritten in a wrapper cookbook to
# any option available in https://github.com/caskdata/hadoop_cookbook.

node.default['hadoop']['distribution'] = "hdp"
node.default['hadoop']['distribution_version'] = "2.2.3"
node.default['hadoop']['home'] = '/usr/lib/hadoop'