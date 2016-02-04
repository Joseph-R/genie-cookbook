name 'genie-cookbook'
maintainer 'Joe Reid'
maintainer_email 'joe.reid@jdpa.com'
license 'all_rights'
description 'Installs/Configures genie-cookbook'
long_description 'Installs/Configures genie-cookbook'
version '0.1.0'

depends 'database', '~> 4.0.6'          # Install/configure local postgres DB
depends 'hadoop', '~> 2.2.0'            # Install Hadoop clients and binaries
depends 'java', '~> 1.39.0'             # Install Oracle JDK for Java version
depends 'tomcat', '~> 1.0.1'            # Install Tomcat