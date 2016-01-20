# Set hadoop attributes
# REQUIRED: Hadoop distribution type and version.
# See https://github.com/caskdata/hadoop_cookbook for details.

node.default['hadoop']['distribution'] = "hdp"
node.default['hadoop']['distribution_version'] = "2.2.3"