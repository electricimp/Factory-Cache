#!/bin/sh

LOCK='/tmp/httpd_keepalive.lock'

if [ -e $LOCK ]
  then
    echo "Already running. Quiting now."
    exit
  else
    touch $LOCK
fi

while true;
do
/opt/sbin/httpd -p 80 -c /jffs/httpd.conf -h /jffs/www/ -f
done
