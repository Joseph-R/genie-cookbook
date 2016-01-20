# Install Java using the community cookbook.
# Uses the Oracle JDK for Java 7, recommended by https://github.com/Netflix/genie/wiki/Setup.

# Install and configure Java with cookbook attributes.
include_recipe "java::default"

# See https://github.com/agileorbit-cookbooks/java for use and example code.