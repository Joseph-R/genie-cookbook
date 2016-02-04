require 'spec_helper'

# Verify that Genie is installed and configured correctly.

catalina_home = '/usr/share/tomcat'
genie_home = '/usr/share/genie'
genie_scripts = %w{jobkill.sh joblauncher.sh localCleanup.py timeout3}

describe port(7000) do
  it { should be_listening }
end

describe file("#{catalina_home}") do
  it { should be_directory }
end

describe file("#{catalina_home}/webapps/ROOT") do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
end

describe file("#{catalina_home}/webapps/genie-jobs") do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
end

describe file("#{catalina_home}/conf/web.xml") do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'tomcat' }
  it { should be_grouped_into 'tomcat' }
end

describe file("#{catalina_home}/webapps/ROOT/WEB-INF/classes/genie.properties") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end


describe file(genie_home) do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'tomcat' }
end

genie_scripts.each do |script|
  describe file("#{genie_home}/#{script}") do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'tomcat' }
  end
end