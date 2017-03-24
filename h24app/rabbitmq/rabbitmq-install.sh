#!/bin/bash
#Time 2016-12-27 9:07
#Author Yo
PATH=/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin
PREFIX=/usr/local
ERLHOME=/usr/local/erlang
RABBITHOME=/usr/local/rabbitmq
RABBITCONF=/etc/rabbitmq
RABBITUSER=rabbit
RABBITPASSWD=rabbit
RABBITTAGS=administrator

mkdir -p ${RABBITCONF}
cp rabbitmq.config ${RABBITCONF}/
cp enabled_plugins ${RABBITCONF}/
yum install ncurses-libs ncurses-devel ncurses -y
yum install openssl-devel openssl -y
yum install autoconf -y
unzip otp-maint.zip
cd otp-maint
./otp_build configure
./configure --prefix=${ERLHOME}
make && make install
ln -s ${ERLHOME}/bin/* /usr/bin/

mkdir ${RABBITHOME}
tar -xvf rabbitmq-server-3.6.5.tar.xz -C ${PREFIX}
mv ${PREFIX}/rabbitmq-server-3.6.5 ${PREFIX}/rabbitmq
cd ${RABBITHOME}
make && make install
ln -s ${RABBITHOME}/scripts/rabbitmq*[!bat] /usr/bin/

sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport 8081 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT" /etc/sysconfig/iptables
/etc/init.d/iptables restart

${RABBITHOME}/scripts/rabbitmqctl add user ${RABBITUSER} ${RABBITPASSWD}
${RABBITHOME}/scripts/rabbitmqctl set_user_tags ${RABBITUSER} ${RABBITTAGS}
${RABBITHOME}/scripts/rabbitmqctl set_permissions -p "/" ${RABBITUSER} ".*" ".*" ".*"
${RABBITHOME}/scripts/rabbitmqctl list_users

:<<BLOCK
rabbitmqctl add user ${RABBITUSER} ${RABBITPASSWD}
rabbitmqctl set_user_tags ${RABBITUSER} ${RABBITTAGS}
rabbitmqctl set_permissions -p "/" ${RABBITUSER} ".*" ".*" ".*"
rabbitmqctl list_users
BLOCK
