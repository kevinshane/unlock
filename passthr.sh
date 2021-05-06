#!/bin/bash
echo "======================================================================="
echo "Choose your CPU architecture                                     by ksh"
echo "======================================================================="
select yn in "Intel" "AMD-Yes"; do
    case $yn in
        Intel) sed -i 's#quiet#quiet intel_iommu=on iommu=pt#' /etc/default/grub
        update-grub
        break
        ;;
        AMD-Yes) sed -i 's#quiet#quiet amd_iommu=on iommu=pt#' /etc/default/grub
        update-grub
        break
        ;;
    esac
done

PCI="$(lspci | grep -i nvidia | awk '{print $1}')"
GPU="$(lspci -n -s $PCI | awk '{print $3}')"

echo "======================================================================="
echo "step 1 --> updating repo ..."
echo "======================================================================="
echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf # laptop lid close do nothing
rm /etc/apt/sources.list.d/pve-enterprise.list # remove enterprise repo
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list # adding no-subs
apt update && apt upgrade -y && apt dist-upgrade -y # update

echo "======================================================================="
echo "step 2 --> blacklisting drivers ..."
echo "======================================================================="
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules # add Required Modules
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf # https://loves.im/?id=42
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf
echo "blacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf
echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf
echo "blacklist snd_hda_codec_hdmi" >> /etc/modprobe.d/blacklist.conf
echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf
update-initramfs -u
echo "options vfio-pci ids=$GPU" > /etc/modprobe.d/vfio.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf

echo "======================================================================="
echo "Done GPU passthrough ! --> please reboot"
echo "======================================================================="