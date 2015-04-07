#!/bin/sh

MAC=`nvram get lan_hwaddr | tr -d ":" | awk '{print tolower($0)}'`
LOCK='/tmp/get_impfirmware.lock'

if [ -e $LOCK ]
  then
    echo "Already running. Quiting now."
    exit
  else
    touch $LOCK
fi


while true; do

  /jffs/opt/bin/wget --read-timeout=300 http://factory-upgrades.electricimp.com/upgrades/$MAC.2.dld -O /jffs/impfirmware.inprogress 2> /tmp/downloadprogress
  WGET_EXIT=$?

  echo "WGET_EXIT: $WGET_EXIT"

  if [[ "$WGET_EXIT" != "0" ]]
  then
    echo "Download Failed. Waiting and Retrying." | tee /tmp/downloadprogress
    sleep 10
  else
    echo "Download Succeeded"
    mv /jffs/impfirmware.inprogress /jffs/impfirmware.dld
    exit
  fi

done;