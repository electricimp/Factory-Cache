#!/bin/sh

FILE=/jffs/impfirmware.dld
echo -ne "Content-type: binary/octet-stream\r\n"
echo -ne "Content-length: " $(wc -c $FILE | sed -e 's/ .*//') "\r\n"
echo -ne "\r\n"
cat $FILE

echo $REQUEST_URI | sed 's|.2.dld||' | sed 's|.*/||' > /tmp/updatedimp
/opt/bin/nohup /jffs/scripts/generate_html.sh &


