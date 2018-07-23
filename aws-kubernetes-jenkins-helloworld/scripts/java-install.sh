#!/usr/bin/env bash
echo "Updating system..."
sudo apt-get -qqy update
echo "############################################################################################"
echo "Adding package Java"
sudo apt-get -qqy install python-software-properties
#You can use `man add-apt-repository` for getting more information.
sudo add-apt-repository -y ppa:webupd8team/java
echo "############################################################################################"
echo "Install Java OpenJDK 9"
sudo apt-get -qqy update
#License Agreement on sudo apt-get -y install oracle-java9-installer
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install unzip git openjdk-7-jdk ant expect
echo "############################################################################################"

sudo chown -R vagrant /etc/profile
sudo chown -R vagrant /etc/bash.bashrc

echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /home/vagrant/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /home/vagrant/.profile
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/bash.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/profile
echo "export PATH=\${PATH}:\${JAVA_HOME}/bin" >> /home/vagrant/.bashrc
echo "export PATH=\${PATH}:\${JAVA_HOME}/bin" >> /home/vagrant/.profile
echo "export PATH=\${PATH}:\${JAVA_HOME}/bin" >> /etc/bash.bashrc
echo "export PATH=\${PATH}:\${JAVA_HOME}/bin" >> /etc/profile

#Reload .bashrc, .profile, /etc/bash.bashrc, /etc/profile
source /home/vagrant/.bashrc
source /home/vagrant/.profile
source /etc/bash.bashrc
source /etc/profile