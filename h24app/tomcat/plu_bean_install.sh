#!/bin/bash
#Time 2017-1-6 16:51
#Author Yo

JAVA_HOME=/usr/local/java
JAVA_JRELIB=${JAVA_HOME}/jre/lib/ext
JAVA_JRESO=${JAVA_HOME}/jre/lib/amd64

tar -xvzf BEAN6.LINUX26.XEON.64B3320.tar.Z
mv trsbean/trsbean.jar ${JAVA_JRELIB}/
mv trsbean/libtrsbean.so ${JAVA_JRESO}/

echo "Plu join success."
