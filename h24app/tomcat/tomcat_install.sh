#!/bin/bash
#Time 2017-1-6 16:40
#Author Yo
PREFIX=/usr/local
TOMCAT_HOME=/usr/local/tomcat
TOMCAT_BIN=/usr/local/tomcat/bin
JAVA_HOME=/usr/local/java
TOMCAT_PORT=8080

echo "Install new java."
tar -xvzf jdk-7u79-linux-x64.tar.gz -C ${PREFIX}
mv ${PREFIX}/jdk1.7.0_79 ${JAVA_HOME}
if [ -f '/usr/bin/java' ];then
	mv /usr/bin/java /usr/bin/java_bk
fi
echo "export JAVA_HOME=${JAVA_HOME}">> /etc/profile
echo "export PATH=\$PATH:${JAVA_HOME}/bin" >> /etc/profile

echo "Install tomcat"
tar -xvzf apache-tomcat-7.0.72.tar.gz -C ${PREFIX}
mv ${PREFIX}/apache-tomcat-7.0.72 ${TOMCAT_HOME}
echo "export TOMCAT_HOME=${TOMCAT_HOME}" >> /etc/profile
echo "export PATH=\$PATH:${TOMCAT_BIN}" >> /etc/profile

echo "accept 8080 in firewall."
sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport ${TOMCAT_PORT} -j ACCEPT" /etc/sysconfig/iptables
/etc/init.d/iptables restart
echo "You need restart this ssh.Get a new bash env.And you can start tomcat with sudo."
echo "You can use catalina.sh start to start your tomcat."

