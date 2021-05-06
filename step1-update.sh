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

echo "======================================================================="
echo "step 1 --> updating repo ..."
echo "======================================================================="
echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf # laptop lid close do nothing
rm /etc/apt/sources.list.d/pve-enterprise.list # remove enterprise repo
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list # adding no-subs
apt update && apt upgrade -y && apt dist-upgrade -y # update

echo "======================================================================="
echo "step 2 --> installing lsd + bat, colorful ls cat ..."
echo "======================================================================="
wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd-musl_0.20.1_amd64.deb
wget https://github.com/sharkdp/bat/releases/download/v0.18.0/bat_0.18.0_amd64.deb
dpkg -i lsd-musl_0.20.1_amd64.deb && rm lsd-musl_0.20.1_amd64.deb
dpkg -i bat_0.18.0_amd64.deb && rm bat_0.18.0_amd64.deb
echo "alias ls='lsd'
alias l='ls -l'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat='bat'" >> ~/.bashrc

# # install zsh and ohmyzsh
# apt install zsh
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# # sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

echo "======================================================================="
echo "step 3 --> adding Modules ..."
echo "======================================================================="
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules # add Required Modules
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf # blacklist the drivers
update-initramfs -u

echo "======================================================================="
echo "Done PVE updated ! --> please reboot"
echo "======================================================================="