#!/usr/local/bin/bash

cd ./jffs
echo "Test Release - " $(date) > bundleinfo
tar czvf ../jffs-test.tgz ./
scp ../jffs-test.tgz demo.electricimp.com:/var/www/cachingrouter/
rm ../jffs-test.tgz
rm bundleinfo
cd ../
