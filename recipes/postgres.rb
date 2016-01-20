# Install and configure a local postgres database for Genie.

# Leverages the following cookbooks:
## https://github.com/opscode-cookbooks/database
## https://github.com/hw-cookbooks/postgresql

# Install and configure postgres server.
include_recipe "postgresql::server"

# Create genie DB with configs from attributes/postgres.rb
include_recipe "database::postgresql"

# Tell the DB cookbook resources how to talk to the DB
postgresql_connection_info = {
  :host     => node['genie']['postgres']['server'],
  :port     => node['genie']['postgres']['port'],
  :username => node['postgresql']['password']['user'],
  :password => "#{node['postgresql']['password']['postgres']}"
}

# Create Genie user and DB, assign permissions
postgresql_database_user "#{node['genie']['postgres']['username']}" do
  connection postgresql_connection_info
  password "#{node['genie']['postgres']['password']}"
  action :create
end

postgresql_database "#{node['genie']['postgres']['database']}" do
  connection postgresql_connection_info
  owner      "#{node['genie']['postgres']['username']}"
  action     :create
end

# Builds each local DB with one user as both super user and admin.
postgresql_database_user "#{node['genie']['postgres']['username']}" do
  connection postgresql_connection_info
  database_name "#{node['genie']['postgres']['database']}"
  privileges [:all]
  action :grant
end


