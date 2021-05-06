#!/bin/bash

# create mdev startup service
1Gfn() {
echo "[Unit]
Description=mdevctl ksh vgpu
After=default.target
[Service]
ExecStart=/root/v-unlock/1q.sh
[Install]
WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
systemctl daemon-reload
systemctl enable mdev-startup.service
sh /root/v-unlock/kill.sh
sh /root/v-unlock/1q.sh
echo "======================================================================="
echo "vGPU is now have 1G vram!"
echo "======================================================================="
}

2Gfn() {
echo "[Unit]
Description=mdevctl ksh vgpu
After=default.target
[Service]
ExecStart=/root/v-unlock/2q.sh
[Install]
WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
systemctl daemon-reload
systemctl enable mdev-startup.service
sh /root/v-unlock/kill.sh
sh /root/v-unlock/2q.sh
echo "======================================================================="
echo "vGPU is now have 2G vram!"
echo "======================================================================="
}

4Gfn() {
echo "[Unit]
Description=mdevctl ksh vgpu
After=default.target
[Service]
ExecStart=/root/v-unlock/4q.sh
[Install]
WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
systemctl daemon-reload
systemctl enable mdev-startup.service
sh /root/v-unlock/kill.sh
sh /root/v-unlock/4q.sh
echo "======================================================================="
echo "vGPU is now have 4G vram!"
echo "======================================================================="
}

echo "======================================================================="
echo "Select which profile when system startup"
echo "Allows starting mdev devices when PVE booting up"
echo "Make sure rebooting PVE when this script excuted"
echo "                                                                 by ksh"
echo "======================================================================="
select yn in "1G" "2G" "4G" "quit"; do
    case $yn in
        1G) 1Gfn
        break
        ;;
        2G) 2Gfn
        break
        ;;
        4G) 4Gfn
        break
        ;;
        quit) exit 0 ;;
    esac
done