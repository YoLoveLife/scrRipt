#!/bin/bash
#Time 2016-12-29 14:30
#Author Yo

IP=192.168.208.130
REDIS_HOME=/usr/local/redis
REDIS_POINT=3
REDIS_PORTSTART=8081
REDIS_PORTEND=$[${REDIS_PORTSTART}+${REDIS_POINT}*2-1]
REDIS_CLUSTER_CONF=${REDIS_HOME}/clusterConf
REDIS_DEMO_CONF=${REDIS_HOME}/redis.conf
REQUIREPASS=`cat ${REDIS_DEMO_CONF}|grep ^requirepass|cut -d" " -f2`
REDIS_LIST=""

for PORT in `seq ${REDIS_PORTSTART} ${REDIS_PORTEND}`;
do
	CLUSTER_EACH=${REDIS_CLUSTER_CONF}/${PORT}
	mkdir -p $CLUSTER_EACH
	cp ${REDIS_DEMO_CONF} ${CLUSTER_EACH}/${PORT}.conf
	sed -i "s/6379/${PORT}/g"  ${CLUSTER_EACH}/${PORT}.conf
	sed -i "s@logfile \".*\"@logfile ${CLUSTER_EACH}\/${PORT}.log@" ${CLUSTER_EACH}/${PORT}.conf
	sed -i "s/dbfilename dump.rdb/dbfilename ${PORT}.rdb/" ${CLUSTER_EACH}/${PORT}.conf
	FLAG=$[$PORT%2]
	if [ ${FLAG} == "0" ];then
	#Slave
		echo "${PORT} is Slave."
		MASTERPORT=$[${PORT}-1]
		sed -i "s/# slaveof <masterip> <masterport>/slaveof ${IP} ${MASTERPORT}/" ${CLUSTER_EACH}/${PORT}.conf
		sed -i "s/# masterauth <master-password>/masterauth ${REQUIREPASS}/" ${CLUSTER_EACH}/${PORT}.conf
	else
	#Cluster
		echo "${PORT} is Cluster"
		sed -i "s@# cluster-enabled yes@cluster-enabled yes@" ${CLUSTER_EACH}/${PORT}.conf
		sed -i "s@# cluster-config-file n.*@cluster-config-file ${CLUSTER_EACH}\/cluster${PORT}.conf@" ${CLUSTER_EACH}/${PORT}.conf
		REDIS_LIST="${IP}:${PORT} ${REDIS_LIST}"
	fi
done
echo "Config Success."
echo "Env."
yum install -y ruby
yum install -y rubygems.noarch rubygems-devel.noarch
gem install -l ./redis-3.2.2.gem
sed -i "s@:password => nil,@:password => \"${REQUIREPASS}\",@" /usr/lib/ruby/gems/1.8/gems/redis-3.2.2/lib/redis/client.rb
for PORT in `seq ${REDIS_PORTSTART} ${REDIS_PORTEND}`;
do
	echo "Start Redis${PORT}."
	CLUSTER_EACH=${REDIS_CLUSTER_CONF}/${PORT}
	${REDIS_HOME}/src/redis-server ${CLUSTER_EACH}/${PORT}.conf	
done
echo "${REDIS_PORTSTART} to ${REDIS_PORTEND} accpet in firewall"
REDIS_MINSTART=$[${REDIS_PORTSTART}+10000]
REDIS_MINEND=$[${REDIS_PORTEND}+10000]
#sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport ${REDIS_PORTSTART}:${REDIS_PORTEND} -j ACCEPT" /etc/sysconfig/iptables
#sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport ${REDIS_MINSTART}:${REDIS_MINEND} -j ACCEPT" /etc/sysconfig/iptables
#/etc/init.d/iptables restart
echo "-A INPUT -p tcp -m tcp --dport ${REDIS_PORTSTART}:${REDIS_PORTEND} -j ACCEPT"
echo "-A INPUT -p tcp -m tcp --dport ${REDIS_MINSTART}:${REDIS_MINEND} -j ACCEPT"
echo "${REDIS_HOME}/src/redis-trib.rb create --replicas 1 ${REDIS_LIST}"
