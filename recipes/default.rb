#
# Cookbook Name:: genie-cookbook
# Recipe:: default
#
# Copyright (c) 2016 Joe Reid, All Rights Reserved.

genie_home = "/usr/share/genie"
catalina_home = "/usr/share/tomcat"

genie_download_path = "#{Chef::Config[:file_cache_path]}/genie-web-#{node['genie']['version']}.war"
genie_download_source = "https://bintray.com/artifact/download/netflixoss/maven/com/netflix/genie/genie-web/#{node['genie']['version']}/genie-web-#{node['genie']['version']}.war"

postgres_jar = "postgresql-9.4.1207.jar"
list_formatting_URL = "https://raw.githubusercontent.com/Netflix/genie/#{node['genie']['version']}/root/apps/tomcat/conf/listings.xsl"

# BUILD GENIE, FOLLOWING INSTRUCTIONS POSTED @ https://github.com/Netflix/genie/wiki/Setup

# PREREQUISITES
## Install Java 
include_recipe "genie-cookbook::java"    

## Install Tomcat
include_recipe "genie-cookbook::tomcat"   

## Install binary version of Hadoop client.
# check out https://github.com/caskdata/hadoop_cookbook/blob/master/attributes/default.rb?
include_recipe "hadoop::default"

# OPTIONAL

## Install a relational database, such as MySQL or PostgreSQL
#@todo - Factor into a conditional that installs DBs based on attribute flags.
include_recipe "genie-cookbook::postgres"


## Install binary distributions of optional clients like Hive/Pig/Presto etc., 
## including the command-line scripts that launch these jobs respectively.

include_recipe "hadoop::hbase"
include_recipe "hadoop::pig"

# Get the Genie WAR
## Download the Binary (Recommended)

remote_file "Download Genie WAR file for #{node['genie']['version']}" do 
  path    "#{genie_download_path}"
  source  "#{genie_download_source}"
  # show_progress true      # Awaiting PR - https://github.com/chef/chef/issues/2812
  retry_delay 5
  retries 12
end


# DEPLOY AND CONFIGURE

## PREREQUISITES
## Assumes you've set CATALINA_HOME to be the root of your Tomcat deployment. If not
### export CATALINA_HOME=/your/path/to/tomcat
## Also if Tomcat already has a ROOT app in $CATALINA_HOME/webapps you should move it or delete it.

# UNZIP THE WAR
## mkdir $CATALINA_HOME/webapps/ROOT &&\

directory "#{catalina_home}/webapps/ROOT" do
  owner 'root'
  group 'tomcat'
  mode  '755'
end

## cd $CATALINA_HOME/webapps/ROOT &&\
## jar xf <where you downloaded or build the war>/genie-web-{version}.war
execute "Unpack Genie war file in #{catalina_home}/webapps/ROOT" do
  command "jar -xf #{genie_download_path}"
  cwd     "#{catalina_home}/webapps/ROOT"
  action  :run
end


# MAKE GENIE-JOBS AND DOWNLOAD LISTING FORMATTING
## mkdir $CATALINA_HOME/webapps/genie-jobs &&\
directory "#{catalina_home}/webapps/genie-jobs" do
  owner 'root'
  group 'tomcat'
  mode  '0755'
end

## wget -q -P $CATALINA_HOME/conf 'https://raw.githubusercontent.com/Netflix/genie/{version}/root/apps/tomcat/conf/listings.xsl'
##@todo - Can we duplicate the -P flag with a remote_file resource?  
##If so, do it and deprecate this execute block and package dependency.
package 'wget'

execute "Download list formatting" do
  command "wget -q -P #{catalina_home}/conf '#{list_formatting_URL}'"
  cwd     "#{catalina_home}"
  action  :run
end


# ENABLE LISTINGS IN TOMCAT TO ALLOW USERS TO VIEW JOB RESULTS VIA BROWSER

## Edit $CATALINA_HOME/conf/web.xml to enable listings by changing the default servlet

# Target should look like this:
# <servlet>
#     <servlet-name>default</servlet-name>
#     <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
#     <init-param>
#         <param-name>debug</param-name>
#         <param-value>0</param-value>
#     </init-param>
#     <init-param>
#         <param-name>listings</param-name>
#         <param-value>true</param-value>
#     </init-param>
#     <init-param>
#         <param-name>globalXsltFile</param-name>
#         <param-value>$CATALINA_HOME/conf/listings.xsl</param-value>
#     </init-param>
#     <load-on-startup>1</load-on-startup>
# </servlet>

template "#{catalina_home}/conf/web.xml" do
  source 'tomcat_web.xml.erb'
  mode '644'
  owner 'tomcat'
  group 'tomcat'
  variables(
    :listings => "true",
    :globalXsltFile => "#{catalina_home}/conf/listings.xsl"
  )
end


# MODIFY DATABASE CONNECTION SETTINGS (OPTIONAL)

# If you don't want to run against the in memory database, aren't using MySQL or your MySQL isn't running on localhost you'll need to modify the database configuration. Genie uses Spring for various functionality including the data access layer. Database connection information is stored in the genie-jpa.xml file.

# You'll find the file in $CATALINA_HOME/webapps/ROOT/WEB-INF/classes

# Edit your configurations as needed. If you're not using MySQL you'll have to chnage the driver class. The connection url will have to be changed if it's not localhost. Currently password is set to nothing so if you have one configured you should set it. Note if you want to use MySQL you'll need to change the spring active profile at runtime which is described below.

remote_file "Download #{postgres_jar}" do 
  action  :create_if_missing
  path    "#{catalina_home}/webapps/ROOT/WEB-INF/lib/#{postgres_jar}"
  source  "https://jdbc.postgresql.org/download/#{postgres_jar}"
  # show_progress true      # Awaiting PR - https://github.com/chef/chef/issues/2812
  owner 'root'
  group 'root'
  mode '644'
  retry_delay 5
  retries 12
  notifies :restart, 'service[tomcat]', :delayed
end

template "#{catalina_home}/webapps/ROOT/WEB-INF/classes/genie-jpa.xml" do
  source 'genie-jpa.xml.erb'
  mode '644'
  owner 'root'
  group 'root'
  variables(
    :data_source_class => node['genie']['postgres']['data_source_class'],
    :driverclass => node['genie']['postgres']['driver_class'],
    :url_connection_string => node['genie']['postgres']['URL_connection_string'],
    :username => node['genie']['postgres']['username'],
    :password => node['genie']['postgres']['password'],
  )
end

# UPDATE SWAGGER ENDPOINT (OPTIONAL)

# Genie ships with integration with Swagger. By default the Swagger json is at http://localhost:7001/genie/swagger.json. If you want your install of Genie to support the Swagger UI, located at http://{genieHost}:{port}/docs/api, you'll need to modify two things if you want to bind the Swagger docs and json to anything other than localhost.

# On line 19 of $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/genie-swagger.xml modify localhost:7001 to match your hostname and port.

# Then in $CATALINA_HOME/webapps/ROOT/WEB-INF/lib you'll find genie-server-{version}.jar. Take this jar and copy it to somewhere like tmp and unzip it. jar xf genie-server-{version}.jar. After the jar is unzipped you'll find the documentation webpage in META-INF/resources/docs/api/index.html. Modify all occurrences of localhost and 7001 to match your deployment. Zip the files back up into a jar.

# The whole process described above should look something like this:

# GENIE_SERVER_JAR_PATH=($CATALINA_HOME/webapps/ROOT/WEB-INF/lib/genie-server-*.jar)
# GENIE_SERVER_JAR_NAME=$(basename ${GENIE_SERVER_JAR_PATH})
# mkdir /tmp/genie-server
# mv ${GENIE_SERVER_JAR_PATH} /tmp/genie-server/
# pushd /tmp/genie-server/
# jar xf ${GENIE_SERVER_JAR_NAME}
# rm ${GENIE_SERVER_JAR_NAME}
# sed -i "s/localhost/${EC2_PUBLIC_HOSTNAME}/g" META-INF/resources/docs/api/index.html
# jar cf ${GENIE_SERVER_JAR_NAME} *
# mv ${GENIE_SERVER_JAR_NAME} ${GENIE_SERVER_JAR_PATH}
# popd
# rm -rf /tmp/genie-server
# sed -i "s/localhost/${EC2_PUBLIC_HOSTNAME}/g" $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/genie-swagger.xml
# Once you've made these changes when you bring up Genie you can navigate to http://{genieHost}:{port}/docs/api to begin using the Swagger UI.


# DOWNLOAD GENIE SCRIPTS

## Genie leverages several scripts to launch and kill client processes when jobs are submitted. You should create a directory on your system (we'll refer to this as GENIE_HOME) to store these scripts and you'll need to reference this location in the property file configuration in the next section.
## Download all the Genie scripts that are used to run jobs

# mkdir -p $GENIE_HOME &&\
# wget -q -P $GENIE_HOME 'https://raw.githubusercontent.com/Netflix/genie/{version}/root/apps/genie/bin/jobkill.sh' &&\
# chmod 755 $GENIE_HOME/jobkill.sh &&\
# wget -q -P $GENIE_HOME 'https://raw.githubusercontent.com/Netflix/genie/{version}/root/apps/genie/bin/joblauncher.sh' &&\
# chmod 755 $GENIE_HOME/joblauncher.sh &&\
# wget -q -P $GENIE_HOME 'https://raw.githubusercontent.com/Netflix/genie/{version}/root/apps/genie/bin/localCleanup.py' &&\
# chmod 755 $GENIE_HOME/localCleanup.py &&\
# wget -q -P $GENIE_HOME 'https://raw.githubusercontent.com/Netflix/genie/{version}/root/apps/genie/bin/timeout3' &&\
# chmod 755 $GENIE_HOME/timeout3
# On line 228 of joblauncher.sh you may have to modify the hadoop conf location. Older Hadoop distros have $HADOOP_HOME/conf/ and newer ones seem to store their conf files in $HADOOP_HOME/etc/hadoop/.

directory "#{genie_home}" do
  owner 'root'
  group 'tomcat'
  mode  '755'
end

%w{jobkill.sh joblauncher.sh localCleanup.py timeout3}.each do |script|
  remote_file "Download #{script}" do 
    path    "#{genie_home}/#{script}"
    source  "https://raw.githubusercontent.com/Netflix/genie/#{node['genie']['version']}/root/apps/genie/bin/#{script}"
    # show_progress true      # Awaiting PR - https://github.com/chef/chef/issues/2812
    owner 'root'
    group 'tomcat'
    mode '755'
    retry_delay 5
    retries 12
  end
end



# MODIFY GENIE PROPERTIES

# Genie properties will be located in $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/genie.properties.
# Environment specific properties will be in $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/genie-{env}.properties. These properties will be loaded by Archaius using the archaius.deployment.environment property in CATALINA_OPTS.

# You should review all the properties in the file but in particular pay attention to the following and set them as need be for your configuration.

# com.netflix.genie.server.java.home
# com.netflix.genie.server.hadoop.home
# netflix.appinfo.port
# com.netflix.genie.server.sys.home
# com.netflix.genie.server.job.dir.prefix
# com.netflix.genie.server.user.working.dir
# com.netflix.genie.server.job.manager.yarn.command.cp
# com.netflix.genie.server.job.manager.yarn.command.mkdir
# com.netflix.genie.server.job.manager.presto.command.cp
# com.netflix.genie.server.job.manager.presto.command.mkdir
# For further information on customizing your Genie install see Customization and Options.

#@todo - Add support for logging to S3 and configuring email notifications.
template "#{catalina_home}/webapps/ROOT/WEB-INF/classes/genie.properties" do
  source 'genie.properties.erb'
  mode '644'
  owner 'root'
  group 'root'
  variables(
    :hostname => node['hostname'],
    :tomcat_port => node['tomcat']['port'],
    :genie_job_path => "#{catalina_home}/webapps/genie-jobs",
    :script_home => "#{genie_home}/",
    :genie_version => node['genie']['version'],
    :java_home => "#{node['java']['java_home']}",
    :aws_access_key => node['genie']['access_key_id'] ? node['genie']['access_key_id'] : "KEY",
    :aws_secret_key => node['genie']['secret_access_key'] ? node['genie']['secret_access_key'] : "SECRET",
    :max_running_jobs => node['genie']['max_running_jobs'],
    :forward_jobs_threshold => node['genie']['forward_jobs_threshold'],
    :hadoop_home => node['hadoop']['home']
  )
end


# Run Tomcat

# Set CATALINA_OPTS to tell Archaius what properties to use as well as what Spring profile to use. By default Genie will use dev for the Spring profile. genie-dev.properties will override properties in genie.properties if -Darchaius.deployment.environment=dev is used. Below example sets Spring profile to prod which will use the prod database connection to MySQL (unless this was modified above).

# export CATALINA_OPTS="-Dspring.profiles.active=prod -Darchaius.deployment.applicationId=genie -Darchaius.deployment.environment=prod"
# If you are running in the cloud (AWS), you should also set -Dnetflix.datacenter=cloud.

# Start up Tomcat as follows:

# $CATALINA_HOME/bin/startup.sh
# Note that the CATALINA_OPTS environment variable must be set, and available to the Tomcat startup script.


service "tomcat" do
  action :nothing
end