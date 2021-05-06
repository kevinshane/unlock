#!/bin/bash
mdevctl stop -u $AAA
mdevctl stop -u $BBB
mdevctl stop -u $CCC
mdevctl stop -u $DDD
mdevctl stop -u $EEE
mdevctl stop -u $FFF
mdevctl stop -u $GGG
mdevctl stop -u $HHH
mdevctl stop -u $III
mdevctl stop -u $JJJ
mdevctl stop -u $KKK
OUTPUT=$(mdevctl list)
echo "${OUTPUT}killed mdev devices"
