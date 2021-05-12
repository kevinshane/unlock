#!/bin/bash
###############--vgpu unlock tools--###############
#  Author : ksh
#  Mail: kevinshane@vip.qq.com
#  Version: v0.0.1
#  Github: https://github.com/kevinshane/unlock
###################################################

runUpdate(){
  # enable iommu group
  if [ `grep "iommu" /etc/default/grub | wc -l` = 0 ];then
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then 
      sed -i 's#quiet#quiet amd_iommu=on iommu=pt#' /etc/default/grub && update-grub
    else
      sed -i 's#quiet#quiet intel_iommu=on iommu=pt#' /etc/default/grub && update-grub
    fi
  else echo "$(tput setaf 2)iommu satisfied 已开启IOMMU √$(tput sgr 0)"
  fi

  # add vfio modules
  if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
    echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules
    else echo "$(tput setaf 2)vfio satisfied 已添加VFIO模组 √$(tput sgr 0)"
  fi

  # blacklist nouveau
  if [ `grep "nouveau" /etc/modprobe.d/blacklist.conf|wc -l` = 0 ];then
    echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf && update-initramfs -u
    else echo "$(tput setaf 2)nouveau satisfied 已屏蔽nouveau驱动 √$(tput sgr 0)"
  fi

  # laptop lid close
  if [ `grep "HandleLidSwitch=ignore" /etc/systemd/logind.conf|wc -l` = 0 ];then
    echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf
  # else echo "$(tput setaf 2)lid satisfied 已设置笔记本屏幕 √$(tput sgr 0)"
  fi

  # remove enterprise repo
  if test -f "/etc/apt/sources.list.d/pve-enterprise.list";then 
    rm /etc/apt/sources.list.d/pve-enterprise.list
  fi

  # add none-ent repo
  if [ `grep "pve-no-subscription" /etc/apt/sources.list|wc -l` = 0 ];then
    echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list
  else echo "$(tput setaf 2)repo satisfied 已设置源 √$(tput sgr 0)"
  fi

  # update
  apt update && apt upgrade -y && apt dist-upgrade -y

  # # install git
  # for app in git
  # do
  #   if [ `dpkg -s $app|grep Status|wc -l` = 1 ];then echo "$(tput setaf 2)√ 已安装$app Already installed $app $(tput sgr 0)"
  #   else 
  #     echo "$(tput setaf 1)× 未安装$app Could not find $app, will install $(tput sgr 0)"
  #     apt install -y $app
  #   fi
  # done

  echo "======================================================================="
  echo "$(tput setaf 2)Done PVE updated ! --> please reboot 搞定！请重启PVE$(tput sgr 0)"
  echo "======================================================================="
  tput sgr 0
}

startUpdate(){
  if [ $L = "cn" ];then
    if (whiptail --title "同意条款及注意事项" --yes-button "继续" --no-button "返回"  --yesno "
    ----------------------------------------------------------------------
    此脚本涉及的命令行操作具备一定程度的硬件损坏风险，固仅供测试
    部署及使用者需自行承担相关操作风险及后果，up主不对任何操作承担相关责任
    ----------------------------------------------------------------------

    PVE无痛自动化:
    1. 一键无脑更新PVE到最新系统
    2. 添加社区源，开启IOMMU支持，添加VFIO模组，屏蔽nouveau驱动
    3. 适合反复食用，已设置或已安装的程序会自动跳过
    4. 保持良好的网络环境

    " 20 80) then
        runUpdate
    else
        main
    fi
  else
    if (whiptail --title "Agreement" --yes-button "Continue" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    You are responible to what you have done in the next step.
    Please do not use for commercial or any production envirment.
    ----------------------------------------------------------------

    PVE Automation:
    1. Auto run apt updating PVE to latest
    2. Adding community repo, VFIO modules, blacklist nouveau
    3. Enable IOMMU depends on hardware
    
    " 20 80) then
        runUpdate
    else
        main
    fi
  fi
  tput sgr 0
}

runUnlock(){
cd /root/
driver="450.80"
# driver="460.32.04"
# driver="440.87"

# install apps
echo "======================================================================="
echo "$(tput setaf 2)installing apps... 正在安装必要软件$(tput sgr 0)"
echo "======================================================================="
for app in build-essential dkms pve-headers git python3-pip jq
do
  if [ `dpkg -s $app|grep Status|wc -l` = 1 ]; then echo "$(tput setaf 2)√ 已安装$app$(tput sgr 0)"
  else 
    echo "$(tput setaf 1)× 未安装$app$(tput sgr 0)"
    apt install -y $app
  fi
done

if [ `pip3 install frida|wc -l` = 2 ]; then echo "$(tput setaf 2)√ 已安装frida$(tput sgr 0)"
else pip3 install frida
fi

# Install driver
echo "======================================================================="
echo "$(tput setaf 2)installing Nvidia $driver Driver... 正在安装原版$driver显卡驱动程序$(tput sgr 0)"
echo "======================================================================="
cd /root/
if test -f "NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run";then 
  chmod +x /root/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run
  /root/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run --dkms
  else
  wget https://github.com/kevinshane/unlock/raw/master/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run
  chmod +x /root/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run
  /root/NVIDIA-Linux-x86_64-$driver-vgpu-kvm.run --dkms
fi

# install vgpu_unlock
echo "======================================================================="
echo "$(tput setaf 2)unlocking... 正在解锁$(tput sgr 0)"
echo "======================================================================="
# vgpu_unlock
cd /root
if [ ! -d "/root/vgpu_unlock" ];then 
  git clone https://github.com/DualCoder/vgpu_unlock.git && chmod -R +x /root/vgpu_unlock/
else echo "$(tput setaf 2)√ 已下载unlock$(tput sgr 0)"
fi

# modify driver
if [ `grep "vgpu_unlock_hooks.c" /usr/src/nvidia-$driver/nvidia/os-interface.c|wc -l` = 0 ];then
  sed -i '20a#include "/root/vgpu_unlock/vgpu_unlock_hooks.c"' /usr/src/nvidia-$driver/nvidia/os-interface.c
fi
if [ `grep "kern.ld" /usr/src/nvidia-$driver/nvidia/nvidia.Kbuild|wc -l` = 0 ];then
  echo "ldflags-y += -T /root/vgpu_unlock/kern.ld" >> /usr/src/nvidia-$driver/nvidia/nvidia.Kbuild
fi
if [ `grep "vgpu_unlock" /lib/systemd/system/nvidia-vgpud.service|wc -l` = 0 ];then
  sed -i 's#ExecStart=#ExecStart=/root/vgpu_unlock/vgpu_unlock #' /lib/systemd/system/nvidia-vgpud.service
fi
if [ `grep "vgpu_unlock" /lib/systemd/system/nvidia-vgpu-mgr.service|wc -l` = 0 ];then
  sed -i 's#ExecStart=#ExecStart=/root/vgpu_unlock/vgpu_unlock #' /lib/systemd/system/nvidia-vgpu-mgr.service
fi

# reaload daemon
systemctl daemon-reload

# remove and reinstall driver
echo "======================================================================="
echo "$(tput setaf 2)reconfiguring driver... 正在重新构建驱动$(tput sgr 0)"
echo "======================================================================="
dkms remove  -m nvidia -v $driver --all
dkms install -m nvidia -v $driver

# install mdev
echo "======================================================================="
echo "$(tput setaf 2)installing mdev... 正在安装mdev设备$(tput sgr 0)"
echo "======================================================================="
cd /root
if [ -x /usr/sbin/mdevctl ];then echo "$(tput setaf 2)√ 已安装mdev$(tput sgr 0)"
else
git clone https://github.com/mdevctl/mdevctl.git
cd mdevctl
make install
fi

# adding 11 uuid to env
if [ `grep "AAA" /etc/environment|wc -l` = 0 ];then
    cat <<EOF >> /etc/environment
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
EOF
else echo "$(tput setaf 2)√ 已添加总共11个UUID环境变量 Already have UUID setup$(tput sgr 0)"
fi

# adding vgpu command
if [ `grep "vgpu" ~/.bashrc|wc -l` = 0 ];then
  echo "alias vgpu='/root/vgpu_unlock/scripts/vgpu-name.sh -p ALL'" >> ~/.bashrc
else echo "$(tput setaf 2)√ 已设置vgpu命令 Already have vgpu command$(tput sgr 0)"
fi

echo "======================================================================="
echo "Done! Please reboot!"
echo "after reboot, you can run <vgpu> to list all support vgpu"
echo "$(tput setaf 2)搞定！请重启PVE！重启后可以运行vgpu查看所有支持的型号$(tput sgr 0)"
echo "                                                                 by ksh"
echo "======================================================================="
tput sgr 0
}

startUnlock(){
  # https://cloud.google.com/compute/docs/gpus/grid-drivers-table
  # google direct download 其他驱动版本下载，请自行下载测试
  # https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-450.89-452.57.zip
  # https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip

  if [ $L = "cn" ];then
    if (whiptail --title "同意条款及注意事项" --yes-button "继续" --no-button "返回-退出"  --yesno "
    ----------------------------------------------------------------------
    此脚本涉及的命令行操作具备一定程度的硬件损坏风险，固仅供测试
    此脚本核心代码均来自网络，up主仅搬运流程并自动化，固版权归属原作者
    部署及使用者需自行承担相关操作风险及后果，up主不对任何操作承担相关责任
    ----------------------------------------------------------------------

    1. 此脚本需主板和CPU同时支持vt-x/vt-d指令集，并且已开启
    2. 某些主板bios选项里有sriov相关选项，请一并开启
    3. 使用超微，戴尔等双路主板时，需在bios里关闭above4G选项
    4. 仅支持9，10，20系N卡！
    5. 使用6，7，8系，30系N卡，yes全系A卡的小伙伴请勿手抖运行！
    6. 仅支持单卡，或同款同类型多卡，不支持不同型号的多卡混插
       如1x1080Ti，或2x2070，同款多卡是支持的
       如1x1080Ti + 1x2070，不同卡是不支持的，拔掉其中一张再执行即可
    7. 保持良好的网络环境
    8. 以上条件缺一不可！

    请认真阅读以上条款，同意回车继续，不同意请退出

    " 25 80) then runUnlock
    else main
    fi
    else
    if (whiptail --title "Agreement" --yes-button "Continue" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    You are responible to what you have done in the next step.
    Please do not use for commercial or any production envirment.
    ----------------------------------------------------------------

    1. Motherboard needs to support vt-x / vt-d
    2. Some MB has SRIOV option, enable them as well
    3. Make sure to turn off Above4G in bios
    4. Only support 9, 10, 20 series
    5. Do not run this script on 6, 7, 8, 30 series
    6. Support only single card
    7. Could run multiple cards with same type, eg. 2x1080Ti
    8. Does not support mixed cards with different type

    Agree to continue, disagree to go back to main menu

    " 25 80) then runUnlock
    else main
    fi
  fi
  tput sgr 0
}

startBeautify(){
if [ $L = "cn" ];then
  whiptail --title "同意条款及注意事项" --msgbox "
  ----------------------------------------------------------------------
  适用于PVE下美化基础LS，CAT，TOP命令，如添加带颜色文件夹图标等
  ----------------------------------------------------------------------

  LS美化 - 执行ls, ll, l, la查看带颜色图标！替代传统ls黑白无图标
  CAT美化- 执行cat命令查看代码高亮，q退出！替代传统cat黑白无高亮
  TOP美化- 执行bpytop查看硬件温度，cpu/内存/硬盘/网络占用！替代传统top
  " 20 75
  else
  whiptail --title "Agreement" --msgbox "
  ----------------------------------------------------------------------
  Script auto installs lsd, bat, bpytop
  ----------------------------------------------------------------------

  beautify ls - A colorful ls command
  beautify cat - A colorful cat command
  beautify top - bpytop - A full hardware monitoring app
  " 20 75
fi

echo "======================================================================="
echo "$(tput setaf 2)step 1 --> installing lsd + bat 正在安装美化程序...(tput sgr 0)"
echo "======================================================================="
wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd-musl_0.20.1_amd64.deb
wget https://github.com/sharkdp/bat/releases/download/v0.18.0/bat_0.18.0_amd64.deb
dpkg -i lsd-musl_0.20.1_amd64.deb && rm lsd-musl_0.20.1_amd64.deb
dpkg -i bat_0.18.0_amd64.deb && rm bat_0.18.0_amd64.deb
if [ `grep "lsd" ~/.bashrc|wc -l` = 0 ];then
cat <<EOF >> ~/.bashrc
alias ls='lsd'
alias l='ls -l'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat='bat'
EOF
else echo "$(tput setaf 2)√ 已添加ls环境变量 Done installing lsd$(tput sgr 0)"
fi

echo "======================================================================="
echo "$(tput setaf 2)step 2 --> installing bpytop 正在安装bpytop...(tput sgr 0)"
echo "======================================================================="
for app in python3-pip
do
  if [ `dpkg -s $app|grep Status|wc -l` = 1 ]; then echo "$(tput setaf 2)√ 已安装$app$(tput sgr 0) Done installing $app"
  else 
    echo "$(tput setaf 1)× 未安装$app$(tput sgr 0)"
    apt install -y $app
  fi
done
pip3 install bpytop --upgrade

echo "======================================================================="
echo "$(tput setaf 2)Done! 搞定！食用方式：bpytop，ls，ll，la，l，cat$(tput sgr 0)"
echo "======================================================================="
}

# pullScript(){
#   # download shell script
#   if test -f "/root/kill.sh"; then echo "Scripts Satisfied !"
#     else
#     githublink="https://raw.githubusercontent.com/kevinshane/unlock/master"
#     wget $githublink/1q.sh && chmod +x /root/1q.sh
#     wget $githublink/2q.sh && chmod +x /root/2q.sh
#     wget $githublink/3q.sh && chmod +x /root/3q.sh
#     wget $githublink/4q.sh && chmod +x /root/4q.sh
#     wget $githublink/kill.sh && chmod +x /root/kill.sh
#   fi
# }

chVram(){
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
  vgpuScriptPath="/root/vgpu_unlock/scripts/vgpu-name.sh"
  v4Q="$($vgpuScriptPath -p ALL | grep -e -4Q | awk '{print $3}')"
  v3Q="$($vgpuScriptPath -p ALL | grep -e -3Q | awk '{print $3}')"
  v2Q="$($vgpuScriptPath -p ALL | grep -e -2Q | awk '{print $3}')"
  v1Q="$($vgpuScriptPath -p ALL | grep -e -1Q | awk '{print $3}')"

  killvgpu(){
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
    echo "${OUTPUT}Released mdev devices 重新释放所有mdev设备"
  }

  # create mdev startup service
  1Gfn() {
    echo "
    [Unit]
    Description=ksh start mdev devices at system startup
    After=default.target
    [Service]
    Type=oneshot
    ExecStart=mdevctl start -u $AAA -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $BBB -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $CCC -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $DDD -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $EEE -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $FFF -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $GGG -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $HHH -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $III -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $JJJ -p 0000:$PCI --type $v1Q
    ExecStart=mdevctl start -u $KKK -p 0000:$PCI --type $v1Q
    ExecStartPost=/bin/sleep 10
    [Install]
    WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
    systemctl daemon-reload
    systemctl enable mdev-startup.service
    killvgpu
    mdevctl start -u $AAA -p 0000:$PCI --type $v1Q
    mdevctl start -u $BBB -p 0000:$PCI --type $v1Q
    mdevctl start -u $CCC -p 0000:$PCI --type $v1Q
    mdevctl start -u $DDD -p 0000:$PCI --type $v1Q
    mdevctl start -u $EEE -p 0000:$PCI --type $v1Q
    mdevctl start -u $FFF -p 0000:$PCI --type $v1Q
    mdevctl start -u $GGG -p 0000:$PCI --type $v1Q
    mdevctl start -u $HHH -p 0000:$PCI --type $v1Q
    mdevctl start -u $III -p 0000:$PCI --type $v1Q
    mdevctl start -u $JJJ -p 0000:$PCI --type $v1Q
    mdevctl start -u $KKK -p 0000:$PCI --type $v1Q
    mdevctl list
    echo "======================================================================="
    echo "$(tput setaf 2)vGPU is now have 1G vram! 显存已更改为1G！$(tput sgr 0)"
    echo "======================================================================="
    tput sgr 0
  }

  2Gfn() {
    echo "
    [Unit]
    Description=ksh start mdev devices at system startup
    After=default.target
    [Service]
    Type=oneshot
    ExecStart=mdevctl start -u $AAA -p 0000:$PCI --type $v2Q
    ExecStart=mdevctl start -u $BBB -p 0000:$PCI --type $v2Q
    ExecStart=mdevctl start -u $CCC -p 0000:$PCI --type $v2Q
    ExecStart=mdevctl start -u $DDD -p 0000:$PCI --type $v2Q
    ExecStartPost=/bin/sleep 10
    [Install]
    WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
    systemctl daemon-reload
    systemctl enable mdev-startup.service
    killvgpu
    mdevctl start -u $AAA -p 0000:$PCI --type $v2Q
    mdevctl start -u $BBB -p 0000:$PCI --type $v2Q
    mdevctl start -u $CCC -p 0000:$PCI --type $v2Q
    mdevctl start -u $DDD -p 0000:$PCI --type $v2Q
    mdevctl list
    echo "======================================================================="
    echo "$(tput setaf 2)vGPU is now have 2G vram! 显存已更改为2G！$(tput sgr 0)"
    echo "======================================================================="
    tput sgr 0
  }

  3Gfn() {
    echo "
    [Unit]
    Description=ksh start mdev devices at system startup
    After=default.target
    [Service]
    Type=oneshot
    ExecStart=mdevctl start -u $AAA -p 0000:$PCI --type $v3Q
    ExecStart=mdevctl start -u $BBB -p 0000:$PCI --type $v3Q
    ExecStart=mdevctl start -u $CCC -p 0000:$PCI --type $v3Q
    ExecStartPost=/bin/sleep 10
    [Install]
    WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
    systemctl daemon-reload
    systemctl enable mdev-startup.service
    killvgpu
    mdevctl start -u $AAA -p 0000:$PCI --type $v3Q
    mdevctl start -u $BBB -p 0000:$PCI --type $v3Q
    mdevctl start -u $CCC -p 0000:$PCI --type $v3Q
    mdevctl list
    echo "======================================================================="
    echo "$(tput setaf 2)vGPU is now have 3G vram! 显存已更改为3G！$(tput sgr 0)"
    echo "======================================================================="
    tput sgr 0
  }

  4Gfn() {
    echo "
    [Unit]
    Description=ksh start mdev devices at system startup
    After=default.target
    [Service]
    Type=oneshot
    ExecStart=mdevctl start -u $AAA -p 0000:$PCI --type $v4Q
    ExecStart=mdevctl start -u $BBB -p 0000:$PCI --type $v4Q
    ExecStartPost=/bin/sleep 10
    [Install]
    WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
    systemctl daemon-reload
    systemctl enable mdev-startup.service
    killvgpu
    mdevctl start -u $AAA -p 0000:$PCI --type $v4Q
    mdevctl start -u $BBB -p 0000:$PCI --type $v4Q
    mdevctl list
    echo "======================================================================="
    echo "$(tput setaf 2)vGPU is now have 4G vram! 显存已更改为4G！$(tput sgr 0)"
    echo "======================================================================="
    tput sgr 0
  }

  if [ $L = "cn" ];then
  whiptail --title "同意条款及注意事项" --msgbox "
  ----------------------------------------------------------------------
  此脚本涉及的命令行操作具备一定程度的硬件损坏风险，固仅供测试
  部署及使用者需自行承担相关操作风险及后果，up主不对任何操作承担相关责任
  ----------------------------------------------------------------------

  当系统重启后，脚本会自动读取上一次切分，无需重复设置
  当需要重新切分显存时，请再次运行该脚本

  请注意：请停止所有VM再运行该脚本！！！
  请注意：请停止所有VM再运行该脚本！！！
  请注意：请停止所有VM再运行该脚本！！！
  " 25 75

  x=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.1 " --menu "
  Github: https://github.com/kevinshane/unlock
  选择配置，回车执行：" 25 60 15 \
  "a" "切分为1G显存" \
  "b" "切分为2G显存" \
  "c" "切分为3G显存" \
  "d" "切分为4G显存" \
  "q" "回主界面" \
  3>&1 1>&2 2>&3)
  else

  whiptail --title "Agreement" --msgbox "
  ----------------------------------------------------------------------
  Script may possible damaging your harware, use at your own risk.
  You are responible to what you have done in the next step.
  Please do not use for commercial or any production envirment.
  ----------------------------------------------------------------------

  When PVE boots up, script remembers the last choice.
  PVE auto creates mdev devices, no need to manually creates.
  Run this app again when you need different vram type.
  The app by default creates Q-series type.

  Please STOP all VM before running this script !!!
  Please STOP all VM before running this script !!!
  Please STOP all VM before running this script !!!
  " 25 75

  x=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.1 " --menu "
  Github: https://github.com/kevinshane/unlock
  select options: " 25 60 15 \
  "a" "slice to 1G vRam" \
  "b" "slice to 2G vRam" \
  "c" "slice to 3G vRam" \
  "d" "slice to 4G vRam" \
  "q" "back to Main Menu" \
  3>&1 1>&2 2>&3)
  fi

  case "$x" in
  a ) 
  # pullScript
  1Gfn
  ;;
  b ) 
  # pullScript
  2Gfn
  ;;
  c ) 
  # pullScript
  3Gfn
  ;;
  d ) 
  # pullScript
  4Gfn
  ;;
  q ) main;;
  esac
  tput sgr 0
}

# --------------------------------------------------------- end function --------------------------------------------------------- #

main(){
  if [ $L = "cn" ];then
  OPTION=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.1 " --menu "
  Github: https://github.com/kevinshane/unlock
  请依照顺序选择配置，回车执行：" 25 60 15 \
  "a" "更新系统" \
  "b" "解锁vGPU" \
  "c" "美化系统" \
  "d" "切分显存" \
  "q" "退出程序" \
  3>&1 1>&2 2>&3)
  else
  OPTION=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.1 " --menu "
  Github: https://github.com/kevinshane/unlock
  select option, enter to apply: " 25 60 15 \
  "a" "Update PVE" \
  "b" "Unlock vGPU" \
  "c" "Beautify PVE" \
  "d" "Change VRAM Size" \
  "q" "Quit" \
  3>&1 1>&2 2>&3)
  fi

  case "$OPTION" in
  a ) startUpdate;;
  b ) startUnlock;;
  c ) startBeautify;;
  d ) chVram;;
  q ) tput sgr 0
      exit;;
  esac
  tput sgr 0
}

if (whiptail --title "Language 选择语言" --yes-button "中文" --no-button "English"  --yesno "Choose Language - 选择语言:" 10 60) then
      L="cn"
  else
      L="en"
fi

main