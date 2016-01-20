# Genie settings.
node.default['genie']['version'] = "2.2.3"

# Performance tuning.  
node.default['genie']['max_running_jobs'] = 30
node.default['genie']['forward_jobs_threshold'] = 20

# AWS
node.default['genie']['access_key_id'] = nil
node.default['genie']['secret_access_key'] = nil