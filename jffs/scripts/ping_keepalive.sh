#!/bin/sh
LOCK='/tmp/ping_keepalive.lock'

if [ -e $LOCK ]
  then
    echo "Already running. Quiting now."
    exit
  else
    touch $LOCK
fi

while true;
do
  /jffs/opt/bin/ping -c 1 imp.electricimp.com

  if [ $? -ne 0]
  then
    echo "Offline"
    echo "Offline" > /tmp/pingstatus
    sleep 10
  else
    echo "Online"
    echo "Online" > /tmp/pingstatus
    sleep 300
  fi     

done
