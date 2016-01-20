# Genie settings.
node.default['genie']['version'] = "2.2.3"
# node.default['genie']['home'] = "#{node['hadoop']['home']}/genie"
# node.default['genie']['port'] = "7000"   

# Increase the max jobs a Genie server can run at one time.  See TR-685.
# node.default['genie']['max_running_jobs'] = "50"
# node.default['genie']['forward_jobs_threshold'] = "60"