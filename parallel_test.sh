#!/bin/bash
wget --limit-rate 20000 http://upgrades.electricimp.com/upgrades/1.2.dld &

for i in `seq 2 $1`;
do
    time wget --limit-rate 20000 http://upgrades.electricimp.com/upgrades/$i.2.dld -o $i.log &
done
wait %1
echo "Waiting for other downloads to finish."
wait