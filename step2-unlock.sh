#!/bin/bash
# google direct download
# https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-450.89-452.57.zip
# https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip

cd /root/
driver="450.80"
# driver="460.32.04"
# driver="440.87"

# install apps
echo "======================================================================="
echo "installing apps..."
echo "======================================================================="
apt install -y build-essential dkms pve-headers git python3-pip jq
pip3 install frida

# Install driver
echo "======================================================================="
echo "installing Nvidia Driver..."
echo "======================================================================="
chmod +x /root/v-unlock/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run
/root/v-unlock/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run --dkms

# install vgpu_unlock
echo "======================================================================="
echo "unlocking..."
echo "======================================================================="
cd /root
git clone https://github.com/DualCoder/vgpu_unlock
chmod -R +x /root/vgpu_unlock/

# modify driver
sed -i '20a#include "/root/vgpu_unlock/vgpu_unlock_hooks.c"' /usr/src/nvidia-$driver/nvidia/os-interface.c
echo "ldflags-y += -T /root/vgpu_unlock/kern.ld" >> /usr/src/nvidia-$driver/nvidia/nvidia.Kbuild
sed -i 's#ExecStart=#ExecStart=/root/vgpu_unlock/vgpu_unlock #' /lib/systemd/system/nvidia-vgpud.service
sed -i 's#ExecStart=#ExecStart=/root/vgpu_unlock/vgpu_unlock #' /lib/systemd/system/nvidia-vgpu-mgr.service

# reaload daemon
systemctl daemon-reload

# remove and reinstall driver
echo "======================================================================="
echo "reconfiguring driver..."
echo "======================================================================="
dkms remove  -m nvidia -v $driver --all
dkms install -m nvidia -v $driver

# install mdev
echo "======================================================================="
echo "installing mdev..."
echo "======================================================================="
cd /root/
git clone https://github.com/mdevctl/mdevctl.git
cd mdevctl
make install

# adding 11 uuid to env
echo "
export AAA=1728f397-99e5-47a6-9e70-ac00d8031596
export BBB=2d5d39f8-80f3-4925-b790-8f7a405b8cb5
export CCC=3b305d4e-88f7-4bea-b2e5-dd436142dc60
export DDD=44da7489-1b80-4e12-93e7-ae2b2b49876f
export EEE=5e694858-12ed-4c55-b57a-c4e889bee0b2
export FFF=6b749fe2-5835-46b5-aff2-19c79b60ddcc
export GGG=7fcb38e2-41c2-4807-80f1-3b79d501f1b5
export HHH=8f601d2d-431a-421c-9f51-49280cfddd8f
export III=94df9f85-44b9-4f48-a81b-8a19f0d19191
export JJJ=108d9d06-eb33-4fe0-8115-cc2d5f6f8589
export KKK=11049ddb-b7ab-4a0c-9111-ab4529b39489
" >> /etc/environment

echo "======================================================================="
echo "Done! Please reboot!"
echo "======================================================================="