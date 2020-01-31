#!/bin/bash


host=`hostname -f`
if (( $(ps -ef | grep pmon | grep -v grep | wc -l) > 0 ))
then
#echo " Oracle is running "
true
else
echo " Oracle Service is not running " | mail -s "Oracle service Alert on server $host"
fi

