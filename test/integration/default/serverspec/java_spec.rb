require 'spec_helper'

# Verify that Oracle 7 is installed for Genie.

describe command('java -version') do
  its(:stderr) { should match /java version \"1.7/ }
  its(:exit_status) { should eq 0 }
end

describe command('source /etc/profile.d/jdk.sh; echo $JAVA_HOME') do
  its(:stdout) { should match "/usr/lib/jvm/java" }
end

describe file('/usr/bin/jar') do
  it { should be_linked_to '/etc/alternatives/jar' }
end