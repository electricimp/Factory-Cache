#!/usr/local/bin/bash

cd ./jffs
date > bundleinfo
tar czvf ../jffs.tgz ./
scp ../jffs.tgz demo.electricimp.com:/var/www/cachingrouter/
rm ../jffs.tgz
rm bundleinfo
cd ../

