#!/bin/bash
# Time 2017-8-21 16:20:07
# Author Yo
# Github github.com/YoLoveLife/scrRipt
# Use for clean cache and log

MAIN_DIR=/storage/nginx/www/news24
MAIN_LOG=/storage/nginx/logs/cleanCacheLog.log
APP_DIR=${MAIN_DIR}/application
CACHE_DIR=${APP_DIR}/cache
LOG_DIR=${APP_DIR}/logs
echo "Time `date "+%Y-%m-%d"`" >> ${MAIN_LOG}
echo "Dir ${CACHE_DIR}:" >> ${MAIN_LOG}
echo `ls -lh ${CACHE_DIR}` >> ${MAIN_LOG}
echo "Dir ${LOG_DIR}:" >> ${MAIN_LOG}
echo `ls -lh ${LOG_DIR}` >> ${MAIN_LOG}
echo "" >> ${MAIN_LOG}

find ${CACHE_DIR}/* -mtime +7 -exec rm -f {} \;
find ${LOG_DIR}/* -mtime +7 -exec rm -f {} \;