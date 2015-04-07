#!/bin/sh

echo -ne "Content-type: text/html\r\n"
echo -ne "\r\n"

echo -ne '<!DOCTYPE html PUBLIC "-//IETF//DTD HTML 2.0//EN"><HTML><HEAD><TITLE>Caching AP Status</TITLE></HEAD>'
echo -ne '<BODY><H1>Router is ' $(cat /tmp/pingstatus) '</H1>'
echo -ne '<p><strong>Date and Time: </strong>' $(date) '</p>'
echo -ne '<p><strong>Software Date: </strong>' $(cat /jffs/bundleinfo) '</p>'
echo -ne '<p><strong>AP MAC Address: </strong>' $(nvram get lan_hwaddr) '</p>'
echo -ne '<p><strong>Load Average: </strong>' $(cat /proc/loadavg) '</p>'
echo -ne '<p><strong>Last Ping: </strong>' $(date -r /tmp/pingstatus) '</p>'
echo -ne '<p><strong>Update Progress: </strong>' $(tail -n 1 /tmp/downloadprogress) '</p>'
echo -ne '<p><strong>Update Completed: </strong>' $(date -r /jffs/impfirmware.dld) '</p>'
echo -ne '<p><strong>Update Image SHA1SUM: </strong>' $(sha1sum /jffs/impfirmware.dld | sed 's/ .*//') '</p>'
echo -ne '<p><strong>Imp Update MAC: </strong>' $(cat /tmp/updatedimp) '</p>'
echo -ne '<p><strong>Imp Update Time: </strong>' $(date -r /tmp/updatedimp) '</p>'
echo -ne '</BODY></HTML>'


