#!/bin/bash
#Install Redis
#Author Yo
:<<BLOCK
if [ $1 == '--help' ]||[$# == 0 ];then
	cat <<_ACEOF
	configure redis_install bash script.
	Usage $0 [OPTION]... [VAR=VALUE]...
	--help 		display this help and exit
	--version	modify the version of redis
	--prefix	modify the prefix.Default /usr/local
	--user		modify the user of redis.Default redis
	--bind		modify the bind of redis-server.Default 0.0.0.0
	--requirepass	modify the passwd of redis-server.Default QB24Hour
_ACEOF
	exit 2
fi
BLOCK
PATH=/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin
VERSION="3.2.4"
PREFIX="/usr/local"
SYSTEM=`uname -a |awk '{print $13}'`
USER="redis"
SHELL="/sbin/nologin"
BIND="0.0.0.0"
REQUIREPASS="QB24Hour"
LOGFILE="/usr/local/redis/redis.log"
DATADIR="/storage"

function Info()
{
	echo "=======INFO======="
}
function Error()
{
	echo "=======ERROR======="
}
Info
echo "Environment Check."
ISGCC=`rpm -qa |grep ^gcc-[1-9].*\.${SYSTEM}|wc -l`
ISMAKE=`rpm -qa|grep ^make.*\.${SYSTEM}|wc -l`
if [ ! `id -u` -eq "0" ];then
	echo "Your are not root."
	exit 1
else
	echo "Your are root"
fi
if [ ! "${ISGCC}" == "0" ];then
	Info
	echo "You Have Installed gcc."
else
	Error
	echo "No gcc environment."
	echo "You can use dnf/yum install gcc."
	exit 1
fi

if [ ! "${ISMAKE}" == "0" ];then
	Info
	echo "You Have Install make."
else
	Error
	echo "No make environment."
	echo "you can use dnf/yum install make."
	exit 1
fi

Info
echo "Prepare for install."
tar -xvzf redis-${VERSION}.tar.gz -C ${PREFIX} &>/dev/null
mv ${PREFIX}/redis-${VERSION} ${PREFIX}/redis
DIRNAME=${PREFIX}/redis
mkdir -p ${DIRNAME}/data
groupadd ${USER}
useradd -s ${SHELL} -g ${USER} ${USER}
chown -R ${USER}:${USER} $DIRNAME
 
Info
echo "Start Install Redis."
cp ${DIRNAME}/src/{redis-cli,redis-server} /usr/bin
make --directory=${DIRNAME} 
if [ $? -eq 0 ];then
	Info
	echo "Make success."
else
	Error
	echo "Error Make.Please check the error info and try again."
	exit 2
fi

Info
echo "Bind ${BIND}.Requirepass ${REQUIREPASS}.
	Logfile ${LOGFILE}.Datadir ${DATADIR}."
sed -i "s/\<bind 127.0.0.1/bind ${BIND}/g" ${DIRNAME}/redis.conf &>/dev/null
sed -i "/requirepass foobared/a\requirepass ${REQUIREPASS}" ${DIRNAME}/redis.conf &>/dev/null
sed -i "s@logfile.*@logfile \"${LOGFILE}\"@g" ${DIRNAME}/redis.conf &>/dev/null
sed -i "s@dir \.\/@dir ${DATADIR}@g" ${DIRNAME}/redis.conf &>/dev/null
sed -i "s@daemonize.*@daemonize yes@" ${DIRNAME}/redis.conf &>/dev/null

Info
echo "Success install redis.Please use the commond redis-server to start."
echo "If you want to have a redis-cluster.Please do not change any conf of redis.Just ./redis_cluster.sh"

