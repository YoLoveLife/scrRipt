#!/bin/bash
#
VERSION="10.1.12"
PREFIX=/usr/local
SYSTEM=`uname -a |awk '{print $13}'`
USER=mysql
DATADIR=/storage/mysql
BASEDIR=${PREFIX}/mysql
SHELL=/sbin/nologin
PORT=3306
function Info()
{
	echo "=======INFO======="
}
function Error()
{
	echo "=======ERROR======="
}

Info
echo "Prepare for install."
FILENAME=mariadb-${VERSION}-linux-${SYSTEM}
tar -xvzf ${FILENAME}.tar.gz -C ${PREFIX}
mv ${PREFIX}/${FILENAME}/ ${BASEDIR}
if [ `cat /etc/passwd |grep mysql|wc -l` == "0" ];then
	groupadd ${USER}
	useradd -s ${SHELL} -g ${USER} ${USER}
else
	echo "user mysql already exist."
fi
mkdir -p ${DATADIR}
chown -R ${USER}:${USER} ${DATADIR}
chown -R ${USER}:${USER} ${BASEDIR}

Info
echo "Start Install Mysql."
${BASEDIR}/scripts/mysql_install_db --basedir=${BASEDIR} --datadir=${DATADIR} --user=${USER} &>/dev/null

Info
echo "Configure."
cp -rf ${BASEDIR}/support-files/my-large.cnf /etc/my.cnf
sed -i "/\[mysqld\]/a\basedir = ${BASEDIR}" /etc/my.cnf
sed -i "/\[mysqld\]/a\datadir = ${DATADIR}" /etc/my.cnf
sed -i "/thread_concurrency \=/a\collation_server\=utf8mb4_unicode_ci" /etc/my.cnf
sed -i "/thread_concurrency \=/a\character-set-server\=utf8mb4" /etc/my.cnf
cp ${BASEDIR}/support-files/mysql.server /usr/bin/mysqld
cp ${BASEDIR}/support-files/mysql.server /etc/init.d/mysqld
cp ${BASEDIR}/bin/mysql /usr/bin/mysql
chkconfig --add mysqld

Info
echo "Firewall 3306/tcp accept."
sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport ${PORT} -j ACCEPT" /etc/sysconfig/iptables
/etc/init.d/iptables restart
Info
echo "Success install mysql.Please use the commond mysqld to start mysql."
