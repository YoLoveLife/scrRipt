#!/bin/bash
# Time 2017-9-12 17:32:27
# Author Yo
# Github github.com/YoLoveLife/scrRipt
# processor
cat /proc/cpuinfo |grep processor|wc -l

free -m|sed -n '2p' |awk '{ print $2 }'

df -h |grep '/$' |awk '{ print $2 }'
