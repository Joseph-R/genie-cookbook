# Genie settings.
node.default['genie']['version'] = "2.2.3"

# Performance tuning.  
node.default['genie']['max_running_jobs'] = "50"
node.default['genie']['forward_jobs_threshold'] = "60"

# AWS
node.default['genie']['access_key_id'] = nil
node.default['genie']['secret_access_key'] = nil

# Hadoop parameters
node.default['hadoop']['home'] = "/usr/lib/hadoop"