# Configure attributes if using a local or Heroku-based Postgres DB.

node.default['genie']['postgres']['username'] = "genie"
node.default['genie']['postgres']['password'] = "jigglypuff"
node.default['genie']['postgres']['server'] = "127.0.0.1"
node.default['genie']['postgres']['port'] = "5432"
node.default['genie']['postgres']['database'] = "genie"

# Configure attributes used by the database cookbook resources to manage the DB. 
node.default['postgresql']['password']['user'] = "postgres"
node.default['postgresql']['password']['postgres'] = "starfish"
node.default['postgresql']['server']['config_change_notify'] = :reload
node.default['postgresql']['config']['listen_addresses'] = 'localhost'

# Legacy code.  Deprecate?
# node.default['genie']['postgres']['java_class'] = "org.postgresql.Driver"
# node.default['genie']['postgres']['connection_properties'] = "minPoolSize=5,acquireRetryAttempts=3,maxPoolSize=20,testConnectionOnCheckout=true"
# node.default['genie']['postgres']['connection_string'] = "postgresql://#{node['genie']['postgres']['server']}:#{node['genie']['postgres']['port']}/#{node['genie']['postgres']['database']}?autoReconnect=true&amp;ssl=true&amp;sslfactory=org.postgresql.ssl.NonValidatingFactory"

# Genie-specific configs.  See genie-jpa.xml template in default.rb.
#node.default['genie']['postgres']['data_source_class'] = "org.springframework.jdbc.datasource.DriverManagerDataSource"
node.default['genie']['postgres']['data_source_class'] = "org.apache.commons.dbcp2.BasicDataSource"
node.default['genie']['postgres']['driver_class'] = "org.postgresql.Driver"
node.default['genie']['postgres']['URL_connection_string'] = "jdbc:postgresql://localhost:#{node['genie']['postgres']['port']}/#{node['genie']['postgres']['database']}"