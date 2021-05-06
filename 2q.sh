#!/bin/bash

AAA="1728f397-99e5-47a6-9e70-ac00d8031596"
BBB="2d5d39f8-80f3-4925-b790-8f7a405b8cb5"
CCC="3b305d4e-88f7-4bea-b2e5-dd436142dc60"
DDD="44da7489-1b80-4e12-93e7-ae2b2b49876f"
EEE="5e694858-12ed-4c55-b57a-c4e889bee0b2"
FFF="6b749fe2-5835-46b5-aff2-19c79b60ddcc"
GGG="7fcb38e2-41c2-4807-80f1-3b79d501f1b5"
HHH="8f601d2d-431a-421c-9f51-49280cfddd8f"
III="94df9f85-44b9-4f48-a81b-8a19f0d19191"
JJJ="108d9d06-eb33-4fe0-8115-cc2d5f6f8589"
KKK="11049ddb-b7ab-4a0c-9111-ab4529b39489"

PCI="$(lspci | grep -i nvidia | grep -i vga | awk '{print $1}')"
DEV="$(/root/vgpu_unlock/scripts/vgpu-name.sh -p ALL | grep -e -2Q | awk '{print $3}')"

mdevctl start -u $AAA -p 0000:$PCI --type $DEV
mdevctl start -u $BBB -p 0000:$PCI --type $DEV
mdevctl start -u $CCC -p 0000:$PCI --type $DEV
mdevctl start -u $DDD -p 0000:$PCI --type $DEV
OUTPUT=$(mdevctl list)
echo "${OUTPUT}"
