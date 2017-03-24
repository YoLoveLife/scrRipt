#!/bin/bash
#Time 2017-1-7- 17:20
#Author Yo

VERSION="1.10.1"
PREFIX=/usr/local
NGINX_HOME=/usr/local/nginx
SYSTEM=`uname -a |awk '{print $13}'`
ISPCRE=`rpm -qa |grep ^pcre-[0-9].*\.${SYSTEM}`
ISZLIB=`rpm -qa |grep ^zlib-[0-9].*\.${SYSTEM}`
PCRE_CODE=""
ZLIB_CODE=""
function Info()
{
	echo "=======INFO======="
}
function Error()
{
	echo "=======ERROR======="
}
function InstallPcre()
{
	tar -xvzf pcre-8.37.tar.gz
	cd pcre-8.37/
	PCRE_CODE=`pwd`/pcre-8.37
	pcre-8.37/configure --prefix=/usr
	make --directory=pcre-8.37/
	make install --directory=pcre-8.37/
	cd ..
}
function InstallZlib()
{
	ZLIB_CODE=`pwd`/zlib-1.2.8
	cd zlib-1.2.8/
	tar -xvzf zlib-1.2.8.tar.gz
	zlib-1.2.8/configure --prefix=/usr
	make --directory=zlib-8.37/
	make install --directory=zlib-8.37/
	cd ..
}
#yum install -y patch openssl make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils
#if [ -n ${ISPCRE} ];then
#	InstallPcre
#	echo 1
#	echo ${ISPCRE}	
#else
#	Info
#	echo "Check for pcre done."
#fi
#
#if [ -n ${ISZLIB} ];then
#	InstallZlib
#	echo 2
#	echo ${ISZLIB}
#else
#	Info
#	echo "Check for zlib done."
#fi
InstallZlib
InstallPcre
tar -xvzf nginx-${VERSION}.tar.gz
cd nginx-${VERSION}
./configure --prefix=/usr/local/nginx --with-pcre=/root/nginx_install/pcre-8.37
make && make install
sed -i "/\:OUTPUT ACCEPT \[0\:0\]/a\-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables
/etc/init.d/iptables restart


