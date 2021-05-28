#!/bin/bash
###############--vgpu unlock tools--###############
#  Author : ksh
#  Mail: kevinshane@vip.qq.com
#  Version: v0.0.3
#  Github: https://github.com/kevinshane/unlock
###################################################

# For errors look in dmesg for:
  # - BAR3 mapped
  # - Magic Found
  # - Key Found
  # - Failed to find ...
  # - Invalid sign or blocks pointer
  # - Generate signature
  # - Signature does not match
  # - Decrypted first block

# nvidia-smi Perf
  # - P0/P1 - Maximum 3D performance
  # - P2/P3 - Balanced 3D performance-power
  # - P8 - Basic HD video playback
  # - P10 - DVD playback
  # - P12 - Minimum idle power consumption

# define 11 uuid, do not modify these uuids
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

vgpuScriptPath="/root/vgpu_unlock/scripts/vgpu-name.sh"
PCI="$(lspci | grep -i nvidia | grep -i vga | grep -E 'GM|GP|TU' | awk '{print $1}')"

startUpdate(){
  runUpdate(){
    # enable iommu group
    if [ `grep "iommu" /etc/default/grub | wc -l` = 0 ];then
      if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then 
        sed -i 's#quiet#quiet amd_iommu=on iommu=pt#' /etc/default/grub && update-grub
        echo "$(tput setaf 2)AMD iommu satisfied 已开启AMD IOMMU √$(tput sgr 0)"
      else
        sed -i 's#quiet#quiet intel_iommu=on iommu=pt#' /etc/default/grub && update-grub
        echo "$(tput setaf 2)Intel iommu satisfied 已开启Intel IOMMU √$(tput sgr 0)"
      fi
    else echo "$(tput setaf 2)iommu satisfied 已开启IOMMU √$(tput sgr 0)"
    fi

    # add vfio modules
    if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
      echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules
      echo "$(tput setaf 2)vfio satisfied 已添加VFIO模组 √$(tput sgr 0)"
      else echo "$(tput setaf 2)vfio satisfied 已添加VFIO模组 √$(tput sgr 0)"
    fi

    # blacklist nouveau
    if [ `grep "nouveau" /etc/modprobe.d/blacklist.conf|wc -l` = 0 ];then
      echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf && update-initramfs -u
      echo "$(tput setaf 2)vfio satisfied 已添加VFIO模组 √$(tput sgr 0)"
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

    # add none-enterprise repo
    if [ `grep "pve-no-subscription" /etc/apt/sources.list|wc -l` = 0 ];then
      echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list
      echo "$(tput setaf 2)repo satisfied 已设置源 √$(tput sgr 0)"
    else echo "$(tput setaf 2)repo satisfied 已设置源 √$(tput sgr 0)"
    fi

    # update
    apt update && apt upgrade -y && apt dist-upgrade -y

    # adding unlock command
    if [ `grep "alias unlock" ~/.bashrc|wc -l` = 0 ];then
      echo "alias unlock='/root/begin.sh'" >> ~/.bashrc
      echo "$(tput setaf 2)√ Done unlock command! 已设置unlock命令$(tput sgr 0)"
    else echo "$(tput setaf 2)√ Done unlock command! 已设置unlock命令$(tput sgr 0)"
    fi

    echo "======================================================================="
    echo "$(tput setaf 2)Done PVE updated ! --> please reboot 搞定！请重启PVE."
    echo "After reboot, you can run <unlock> to bring back this script."
    echo "重启后运行unlock命令可启动该脚本$(tput sgr 0)"
    echo "======================================================================="
    tput sgr 0
  }
  if [ $L = "cn" ];then # CN
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
  else # EN
    if (whiptail --title "Agreement" --yes-button "Continue" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    You are responible to what you have done in the next step.
    Please do not use for commercial or any production environment.
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

startUnlock(){
  runUnlock(){
    cd /root/
    # driver="440.87"
    driver="450.80"
    # driver="460.32.04"

    # install apps
    echo "======================================================================="
    echo "$(tput setaf 2)installing apps... 正在安装必要软件$(tput sgr 0)"
    echo "======================================================================="
    for app in build-essential dkms pve-headers git python3-pip jq
    do
      if [ `dpkg -s $app|grep Status|wc -l` = 1 ]; then echo "$(tput setaf 2)√ Already installed $app! 已安装$app$(tput sgr 0)"
      else 
        echo "$(tput setaf 1)× You don't have $app install! 未安装$app$(tput sgr 0)"
        echo "$(tput setaf 2)installing $app! 正在安装$app$(tput sgr 0)"
        apt install -y $app
        echo "$(tput setaf 2)√ Done $app installed! 已安装$app$(tput sgr 0)"
      fi
    done

    if [ `pip3 install frida|wc -l` = 2 ]; then echo "$(tput setaf 2)√ Already installed $app! 已安装frida$(tput sgr 0)"
    else 
    pip3 install frida
    echo "$(tput setaf 2)installing $app! 正在安装$app$(tput sgr 0)"
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
    else echo "$(tput setaf 2)√ Done cloned unlock! 已下载unlock$(tput sgr 0)"
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
    if [ -x /usr/sbin/mdevctl ];then echo "$(tput setaf 2)√ mdev installed! 已安装mdev$(tput sgr 0)"
    else
    git clone https://github.com/mdevctl/mdevctl.git
    cd mdevctl
    make install
    fi

  # adding 11 uuid to env
  if [ `grep "AAA" /etc/environment|wc -l` = 0 ];then
    cat <<EOF >> /etc/environment
export AAA=$AAA
export BBB=$BBB
export CCC=$CCC
export DDD=$DDD
export EEE=$EEE
export FFF=$FFF
export GGG=$GGG
export HHH=$HHH
export III=$III
export JJJ=$JJJ
export KKK=$KKK
EOF
    else echo "$(tput setaf 2)√ Done setup 11 UUID env! 已添加总共11个UUID环境变量$(tput sgr 0)"
    fi

    # adding vgpu command
    if [ `grep "vgpu" ~/.bashrc|wc -l` = 0 ];then
      echo "alias vgpu='/root/vgpu_unlock/scripts/vgpu-name.sh -p ALL'" >> ~/.bashrc
    else echo "$(tput setaf 2)√ Done vgpu command! 已设置vgpu命令$(tput sgr 0)"
    fi

    echo "======================================================================="
    echo "$(tput setaf 2)Done! Please reboot!"
    echo "after reboot, you can run <vgpu> to list all support vgpu"
    echo "搞定！请重启PVE！重启后可以运行vgpu查看所有支持的型号"
    echo "                                                                 by ksh"
    echo "======================================================================="
    tput sgr 0
  }
  # https://cloud.google.com/compute/docs/gpus/grid-drivers-table
  # google direct download 其他驱动版本下载，请自行下载测试
  # https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-450.89-452.57.zip
  # https://storage.googleapis.com/nvidiaowo/NVIDIA-GRID-Linux-KVM-460.32.04-460.32.03-461.33.zip

  if [ $L = "cn" ];then
    if (whiptail --title "同意条款及注意事项" --yes-button "同意" --no-button "返回"  --yesno "
    ----------------------------------------------------------------------
    此脚本涉及的命令行操作具备一定程度损坏硬件的风险，固仅供测试
    此脚本核心代码均来自网络，up主仅搬运流程并自动化，固版权归属原作者
    部署及使用者需自行承担相关操作风险及后果，up主不对操作承担任何相关责任
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

    请认真阅读以上条款，同意回车继续，不同意请退出

    " 25 80) then runUnlock
    else main
    fi
    else
    if (whiptail --title "Agreement" --yes-button "I Agree" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    I'll not take responible to what you have done in the next step.
    Please do not use for commercial or any production environment.
    Credits to vgpu_unlock github that make this happen.
    ----------------------------------------------------------------

    1. Motherboard needs to support vt-x / vt-d
    2. Some MB has SRIOV option, enable them as well
    3. For dual sockets make sure to turn off Above4G in bios
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
  installBeautify(){
  echo "======================================================================="
  echo "$(tput setaf 2)step 1 --> installing lsd + bat 正在安装美化程序...$(tput sgr 0)"
  echo "======================================================================="
  wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb
  wget https://github.com/sharkdp/bat/releases/download/v0.18.1/bat_0.18.1_amd64.deb
  dpkg -i lsd_0.20.1_amd64.deb && rm lsd_0.20.1_amd64.deb
  dpkg -i bat_0.18.1_amd64.deb && rm bat_0.18.1_amd64.deb
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
  else echo "$(tput setaf 2)√ Done lsd installed! 已添加ls环境变量$(tput sgr 0)"
  fi

  echo "======================================================================="
  echo "$(tput setaf 2)step 2 --> installing bpytop 正在安装bpytop...$(tput sgr 0)"
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
  echo "$(tput setaf 2)Done! Please restart SSH! 搞定！请重启SSH，食用方式：bpytop，ls，ll，la，l，cat$(tput sgr 0)"
  echo "======================================================================="
  }
  if [ $L = "cn" ];then
  if (whiptail --title "同意条款及注意事项" --yes-button "继续" --no-button "返回"  --yesno "
  ----------------------------------------------------------------------
  适用于PVE下美化基础LS，CAT，TOP命令，如添加带颜色文件夹图标等
  ----------------------------------------------------------------------

  LS美化 - 执行ls, ll, l, la查看带颜色图标！替代传统ls黑白无图标
  CAT美化- 执行cat命令查看代码高亮，q退出！替代传统cat黑白无高亮
  TOP美化- 执行bpytop查看硬件温度，cpu/内存/硬盘/网络占用！替代传统top
  " 20 75) then installBeautify
  else main
  fi

  else
  
  if (whiptail --title "Agreement" --yes-button "Continue" --no-button "Go Back"  --yesno "
  ----------------------------------------------------------------------
  Script auto installs lsd, bat, bpytop
  ----------------------------------------------------------------------

  beautify ls - A colorful ls command
  beautify cat - A colorful cat command
  beautify top - bpytop - A full hardware monitoring app
  " 20 75) then installBeautify
  else main
  fi
  fi
}

checkStatus(){
  memory=$(nvidia-smi --query-gpu=memory.total --format=csv | awk '/^memory/ {getline; print}' | awk '{print $1}')

  # check if currently has sliced mdev, if returns a list, then no sliced mdev
  if [ ! `$vgpuScriptPath -p ALL | grep -w "$(mdevctl list | grep -m1 nvidia | awk '{print $3}')" | wc -l` = 1 ];then
    currentType=0
    Vnum=0
    Vmemory=$(($memory / 1000))
    float=0
  else
    currentType=$($vgpuScriptPath -p ALL | grep -w "$(mdevctl list | grep -m1 nvidia | awk '{print $3}')")
    Vnum=$(echo "$currentType" | grep -o '[[:digit:]]*' | sed -n '2p')
    Vmemory=$(($memory / 1000))
    float=$(($Vmemory / $Vnum))
  fi

  if [[ $L = "cn" ]];then # CN
  echo "$(tput setaf 2)  ===================================================================
    - 物理显卡参数
    型号：$(nvidia-smi --query-gpu=gpu_name --format=csv | sed -n '2p')
    总线：$(nvidia-smi --query-gpu=gpu_bus_id --format=csv | sed -n '2p')
    温度：$(nvidia-smi --query-gpu=temperature.gpu --format=csv | sed -n '2p')°C
    功耗：$(nvidia-smi --query-gpu=power.draw --format=csv | sed -n '2p')
    显存：$memory兆

    - 切分建议
    1）当切分为1G显存时，可同时运行$(($Vmemory / 1))台VM虚拟机
    2）当切分为2G显存时，可同时运行$(($Vmemory / 2))台VM虚拟机
    3）当切分为3G显存时，可同时运行$(($Vmemory / 3))台VM虚拟机
    4）当切分为4G显存时，可同时运行$(($Vmemory / 4))台VM虚拟机
    5）当切分为6G显存时，可同时运行$(($Vmemory / 6))台VM虚拟机
    6）当切分为8G显存时，可同时运行$(($Vmemory / 8))台VM虚拟机

    - 当前切分状态
    切分型号：$currentType
    切分显存："$Vnum"G
    可供使用的vGPU数量：$float个
                                                                -- by ksh
  =======================================================================$(tput sgr 0)"

  else # EN
  echo "$(tput setaf 2)  ===================================================================
    - Graphic Card
    Type: $(nvidia-smi --query-gpu=gpu_name --format=csv | sed -n '2p')
    BusID: $(nvidia-smi --query-gpu=gpu_bus_id --format=csv | sed -n '2p')
    Temp: $(nvidia-smi --query-gpu=temperature.gpu --format=csv | sed -n '2p')°C
    Power: $(nvidia-smi --query-gpu=power.draw --format=csv | sed -n '2p')
    Vram: $memory Mib

    - Slice Tips
    1) When slicing to 1G Vram, it can run up to $(($Vmemory / 1)) VM simultaneously
    2) When slicing to 2G Vram, it can run up to $(($Vmemory / 2)) VM simultaneously
    3) When slicing to 3G Vram, it can run up to $(($Vmemory / 3)) VM simultaneously
    4) When slicing to 4G Vram, it can run up to $(($Vmemory / 4)) VM simultaneously
    5) When slicing to 6G Vram, it can run up to $(($Vmemory / 6)) VM simultaneously
    6) When slicing to 8G Vram, it can run up to $(($Vmemory / 8)) VM simultaneously

    - vGPU slicing status
    Sliced type: $currentType
    Sliced vRam: "$Vnum"G
    Current Available Count: $float
                                                                -- by ksh
  =======================================================================$(tput sgr 0)" 
  fi
}

chVram(){
  startVramSlice(){
    vxQ="$($vgpuScriptPath -p ALL | grep -e -"$selectVram"Q | awk '{print $3}')"
    memory=$(nvidia-smi --query-gpu=memory.total --format=csv | awk '/^memory/ {getline; print}' | awk '{print $1}')
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
      echo "Released mdev devices 重新释放所有mdev设备"
    }

    killvgpu

    mdevctl start -u $AAA -p 0000:$PCI --type $vxQ
    mdevctl start -u $BBB -p 0000:$PCI --type $vxQ
    mdevctl start -u $CCC -p 0000:$PCI --type $vxQ
    mdevctl start -u $DDD -p 0000:$PCI --type $vxQ
    mdevctl start -u $EEE -p 0000:$PCI --type $vxQ
    mdevctl start -u $FFF -p 0000:$PCI --type $vxQ
    mdevctl start -u $GGG -p 0000:$PCI --type $vxQ
    mdevctl start -u $HHH -p 0000:$PCI --type $vxQ
    mdevctl start -u $III -p 0000:$PCI --type $vxQ
    mdevctl start -u $JJJ -p 0000:$PCI --type $vxQ
    mdevctl start -u $KKK -p 0000:$PCI --type $vxQ

    echo "
    [Unit]
    Description=ksh start mdev devices at system startup
    After=default.target
    [Service]
    Type=oneshot
    ExecStart=mdevctl start -u $AAA -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $BBB -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $CCC -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $DDD -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $EEE -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $FFF -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $GGG -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $HHH -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $III -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $JJJ -p 0000:$PCI --type $vxQ
    ExecStart=mdevctl start -u $KKK -p 0000:$PCI --type $vxQ
    ExecStartPost=/bin/sleep 10
    [Install]
    WantedBy=default.target" > /etc/systemd/system/mdev-startup.service
    systemctl daemon-reload
    systemctl enable mdev-startup.service

    currentType=$($vgpuScriptPath -p ALL | grep -w "$(mdevctl list | grep -m1 nvidia | awk '{print $3}')")
    # Vnum=$(echo "$currentType" | grep -o '[[:digit:]]*' | sed -n '2p')
    Vnum=$($vgpuScriptPath -p ALL | grep -e -"$selectVram"Q | grep -o '[[:digit:]]*' | sed -n '2p')
    Vmemory=$(($memory / 1000))
    float=$(($Vmemory / $Vnum))

  echo "$(tput setaf 2)
  ===================================================================
  物理显存: $memory兆
  当前切分状态:
  切分型号: $currentType
  当前vGPU显存为"$Vnum"G，可供使用的vGPU数量为$float个

  TotalVram: $memory Mib
  Slicing Status:
  vGPU Type: $currentType
  Current vGPU vRAM is "$Vnum"G, available vGPU count is $float
  ===================================================================$(tput sgr 0)"
  }

  if [ $L = "cn" ];then # CN
    if (whiptail --title "同意条款及注意事项" --yes-button "同意" --no-button "返回"  --yesno "
    ----------------------------------------------------------------------
    此脚本涉及的命令行操作具备一定程度损坏硬件的风险，固仅供测试
    此脚本核心代码均来自网络，up主仅搬运流程并自动化，固版权归属原作者
    部署及使用者需自行承担相关操作风险及后果，up主不对操作承担任何相关责任
    ----------------------------------------------------------------------

    当系统重启后，脚本会自动读取上一次切分，无需重复设置
    当需要重新切分显存时，请再次运行该脚本

    请注意：请停止所有VM再运行该脚本！！！
    请注意：请停止所有VM再运行该脚本！！！
    请注意：请停止所有VM再运行该脚本！！！
    " 20 80) then

    selectVram=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.3 " --menu "
    选择配置，回车执行：" 25 60 15 \
    "a" "切分为1G显存" \
    "b" "切分为2G显存" \
    "c" "切分为3G显存" \
    "d" "切分为4G显存" \
    "q" "回主界面" \
    3>&1 1>&2 2>&3)
    case "$selectVram" in
    a )	selectVram=1
      ;;

    b ) selectVram=2
      ;;

    c ) selectVram=3
      ;;

    d ) selectVram=4
      ;;

    q ) main;;
    esac
    startVramSlice
    else main
    fi

  else # EN

    if (whiptail --title "Agreement" --yes-button "I Agree" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    I'll not take responible to what you have done in the next step.
    Please do not use for commercial or any production environment.
    Credits to vgpu_unlock github that make this happen.
    ----------------------------------------------------------------

    When PVE boots up, script remembers the last choice.
    PVE auto creates mdev devices, no need to manually creates.
    Run this script again when you need different vram type.
    The script by default creates Q-series type.

    Please STOP all VM before running this script !!!
    Please STOP all VM before running this script !!!
    Please STOP all VM before running this script !!!
    " 24 80) then

    selectVram=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.3 " --menu "
    select options: " 25 60 15 \
    "a" "slice to 1G vRam" \
    "b" "slice to 2G vRam" \
    "c" "slice to 3G vRam" \
    "d" "slice to 4G vRam" \
    "q" "back to Main Menu" \
    3>&1 1>&2 2>&3)
    case "$selectVram" in
    a )	selectVram=1
      ;;

    b ) selectVram=2
      ;;

    c ) selectVram=3
      ;;

    d ) selectVram=4
      ;;

    q ) main;;
    esac
    startVramSlice
    else main
    fi

  fi
}

deployQuadro(){

  runQuadro(){
    IDofTU="1EB1" #RTX4000
    SubIDofTU="12A0"

    IDofGP="1B30" #P6000
    SubIDofGP="11A0"

    IDofGM="13F0" #M5000
    SubIDofGM="1152"

    # delete any vgpu uuid conf if exist
    sed -i '/args: -uuid/d' /etc/pve/qemu-server/$vmid.conf

    # modify vm conf depends on gpu architecture
    if [ `grep -E "$AAA|$BBB|$CCC|$DDD|$EEE|$FFF|$GGG|$HHH|$III|$JJJ|$KKK" /etc/pve/qemu-server/$vmid.conf|wc -l` = 0 ]; then
      # if GP pascal
      if [ ! `lspci | grep GP | wc -l` = 0 ]; then
        if [ $uuidnumb = 1 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$AAA,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $AAA" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 2 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$BBB,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $BBB" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 3 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$CCC,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $CCC" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 4 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$DDD,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $DDD" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 5 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$EEE,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $EEE" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 6 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$FFF,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $FFF" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 7 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GGG,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $GGG" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 8 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$HHH,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $HHH" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 9 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$III,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $III" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 10 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$JJJ,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $JJJ" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 11 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$KKK,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGP,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGP' -uuid $KKK" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

      
      fi

      # if TU turling  
      if [ ! `lspci | grep TU | wc -l` = 0 ]; then

        sed -i '/mdev/d' /etc/pve/qemu-server/$vmid.conf
        sed -i '/-uuid/d' /etc/pve/qemu-server/$vmid.conf

        if [ $uuidnumb = 1 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$AAA,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $AAA" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 2 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$BBB,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $BBB" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 3 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$CCC,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $CCC" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 4 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$DDD,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $DDD" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 5 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$EEE,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $EEE" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 6 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$FFF,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $FFF" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 7 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GGG,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $GGG" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 8 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$HHH,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $HHH" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 9 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$III,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $III" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 10 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$JJJ,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $JJJ" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 11 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$KKK,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofTU,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofTU' -uuid $KKK" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

      
      fi

      # if GM maxwell
      if [ ! `lspci | grep GM | wc -l` = 0 ]; then
        if [ $uuidnumb = 1 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$AAA,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $AAA" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 2 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$BBB,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $BBB" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 3 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$CCC,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $CCC" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 4 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$DDD,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $DDD" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 5 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$EEE,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $EEE" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 6 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$FFF,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $FFF" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 7 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$GGG,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $GGG" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 8 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$HHH,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $HHH" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 9 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$III,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $III" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 10 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$JJJ,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $JJJ" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi

        if [ $uuidnumb = 11 ]; then
        sed -r -i "1i args: -device 'vfio-pci,sysfsdev=/sys/bus/mdev/devices/$KKK,display=off,id=hostpci0.0,bus=ich9-pcie-port-1,addr=0x0.0,x-pci-vendor-id=0x10de,x-pci-device-id=0x$IDofGM,x-pci-sub-vendor-id=0x10de,x-pci-sub-device-id=0x$SubIDofGM' -uuid $KKK" /etc/pve/qemu-server/$vmid.conf
        echo "$(tput setaf 2)Done modified $vmid! 已完成虚拟机ID为$vmid的Quadro显卡直通！$(tput setaf 0)"
        fi


      fi

      # otherwise
      else
      echo "$(tput setaf 1)Already modified! Please check VM conf: $vmid $(tput setaf 0)"
      echo "$(tput setaf 1)虚拟机ID$vmid已存在Quadro显卡，已跳过！ $(tput setaf 0)"
    fi
  }

  if [ $L = "cn" ];then # CN
    if (whiptail --title "同意条款及注意事项" --yes-button "同意" --no-button "返回"  --yesno "
    自动检测主板当前的物理显卡
    并直通为相对应架构的专业卡

    - 如为9系，则自动解锁为M5000专业显卡
    - 如为10系，则自动解锁为P6000专业显卡
    - 如为20系，则自动解锁为RTX4000专业显卡

    请注意：该脚本不支持6,7,8系和30系物理显卡" 15 80) then
    typeuuid(){ # typing uuid
      uuidnumb=$(whiptail --inputbox "请输入UUID，默认是1，可选范围1-11" 8 60 1 --title "定义UUID值" 3>&1 1>&2 2>&3)
      exitstatus=$?
      if [ $exitstatus = 0 ]; then
          if [ "$uuidnumb" -le 11 -a "$vmid" -ge 1 ]; then runQuadro
          else 
          whiptail --title "Warnning" --msgbox "Invalid UUID. Choose between 1-11! 请重新输入1-11范围内的数字！" 10 60
          typeuuid
          fi
      fi
    }

    vmid=$(whiptail --inputbox "请输入你希望添加vGPU的虚拟机ID值，默认是101" 8 60 101 --title "输入VM的ID值" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then typeuuid
        else 
        whiptail --title "Warnning" --msgbox "请重新输入100-999范围内的数字！" 10 60
        deployQuadro
        fi
    fi
  else main
  fi

  else # EN
    if (whiptail --title "Notice" --yes-button "I Agree" --no-button "Go Back"  --yesno "
    Script auto detect graphics card on motherboard
    Then passthrough with appropriate Quadro

    - 9 series unlock to a M4000 Quadro
    - 10 series unlock to a P6000 Quadro
    - 20 series unlock to a RTX4000 Quadro

    Please be aware, 6,7,8 and 30 series are not supported" 15 80) then
    typeuuid(){ # typing uuid
        uuidnumb=$(whiptail --inputbox "Typing UUID, 1-11 available. Default is 1" 8 60 1 --title "Define UUID" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if [ "$uuidnumb" -le 11 -a "$vmid" -ge 1 ]; then runQuadro
            else 
            whiptail --title "Warnning" --msgbox "Invalid UUID. Choose between 1-11!" 10 60
            typeuuid
            fi
        fi
    }
    
    vmid=$(whiptail --inputbox "What's the VM id you want to add a Quadro? default is 101" 8 60 101 --title "define VM ID" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then typeuuid
        else 
        whiptail --title "Warnning" --msgbox "Invalid VM ID. Choose between 100-999!" 10 60
        fi
    fi
    else main
    fi
  fi
}

deployvGPU(){
  vGPUassign(){

    # delete any quadro conf if exist
    sed -i '/vfio-pci,sysfsdev=/d' /etc/pve/qemu-server/$vmid.conf
    sed -i '/mdev/d' /etc/pve/qemu-server/$vmid.conf
    sed -i '/args: -uuid/d' /etc/pve/qemu-server/$vmid.conf

    # # for vGPU wip
    # vmlist=($(qm list | sed '1d' | awk '{print $1}'))
    # # array=($(sed -E 's/([[:alnum:]]+)/"&"/g;s/ /,/g' <<< ${vmlist[@]}))
    # array=($(sed -E 's/([[:alnum:]]+)/"&"/g' <<< ${vmlist[@]}))
    # vmid=$(whiptail --title "choose VM" --checklist "Select VM" 22 80 14 "${array[@]}")
    # cat *.conf | grep -i args | awk '{print $3}'

    # config mdev vgpu with license
    # qm list|sed '1d'|awk '{print $1}'|while read line ; do mdevctl stop -u 00000000-0000-0000-0000-000000000$line; done
    # qm list|sed '1d'|awk '{print $1}'|while read line ; do mdevctl start -u 00000000-0000-0000-0000-000000000$line -p 0000:$PCI --type $vxQ; done

    # stop current mdev
    qm list|sed '1d'|awk '{print $1}'|while read line ; 
    do 
      if [ `grep -E "mdev=" /etc/pve/qemu-server/*.conf|wc -l` = 1 ];then
        mdevctl stop -u 00000000-0000-0000-0000-000000000$line
      fi;
    done

    # adding mdev
    # sed -i -r "1i hostpci0: $PCI,mdev=$vGPUtype" /etc/pve/qemu-server/$vmid.conf

    # adding uuid to conf
    sed -i -r "1i args: -uuid 00000000-0000-0000-0000-000000000$vmid" /etc/pve/qemu-server/$vmid.conf

    echo "$(tput setaf 2)vGPU assigned! Go to PVE webGui->VM$vmid->Hardward->add PCI device->choose your desire vGPU type$(tput setaf 0)"
    echo "$(tput setaf 2)设置完毕！请到网页端->虚拟机$vmid->硬件->PCI设备->添加你希望的类型$(tput setaf 0)"
  }

  vmidinput(){
    if [ $L = "cn" ];then # CN
      vmid=$(whiptail --inputbox "请输入你希望添加vGPU的虚拟机ID值，默认是101" 8 60 101 --title "输入VM的ID值" 3>&1 1>&2 2>&3)
      exitstatus=$?
      if [ $exitstatus = 0 ]; then
        if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then vGPUassign
        else 
        whiptail --title "Warnning" --msgbox "请重新输入100-999范围内的数字！" 10 80
        deployvGPU
        fi
      fi

    else # EN
      vmid=$(whiptail --inputbox "What's the VM id you want to add a vGPU? default is 101" 8 60 101 --title "define VM ID" 3>&1 1>&2 2>&3)
      exitstatus=$?
      if [ $exitstatus = 0 ]; then
          if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then vGPUassign
          else 
          whiptail --title "Warnning" --msgbox "Invalid VM ID. Choose between 100-999!" 10 60
          fi
      else main
      fi

    fi
  }

  if [ $L = "cn" ];then # CN
    if (whiptail --title "同意条款及注意事项" --yes-button "同意" --no-button "返回"  --yesno "
    ----------------------------------------------------------------------
    此脚本涉及的命令行操作具备一定程度损坏硬件的风险，固仅供测试
    此脚本核心代码均来自网络，up主仅搬运流程并自动化，固版权归属原作者
    部署及使用者需自行承担相关操作风险及后果，up主不对操作承担任何相关责任
    ----------------------------------------------------------------------
    脚本自动添加vGPU到指定VM，从而获得高性能硬件加速
    Quadro与vGPU最大的区别：
    1. 解锁成Quadro免费，解锁成vGPU需要授权服务器和购买许可
    2. Quadro没有CUDA，vGPU有CUDA
    3. Quadro的OpenGL性能略微强过vGPU

    此脚本仅自动化vGPU直通，绿色环保无痛部署:P
    up主本人不提供任何相关授权信息及购买渠道
    一切关于部署授权费用等信息，请咨询专业机构购买正版许可
    或自行注册申请90天试用授权
    " 20 80) then vmidinput
    else main
    fi

  else # EN

    if (whiptail --title "Agreement" --yes-button "I Agree" --no-button "Go Back"  --yesno "
    ----------------------------------------------------------------
    Script may possible damaging your harware, use at your own risk.
    I'll not take responible to what you have done in the next step.
    Please do not use for commercial or any production environment.
    Credits to vgpu_unlock github that make this happen.
    ----------------------------------------------------------------
    Auto assigning vGPU to VM

    This script will only automate the assigning process.
    I will not provide any license info for this script.
    Please either consulting with a professional for more license detail.
    Or you could sign up a 90 day trials on nvidia website.
    GL & HF to you guys :)

    " 20 80) then vmidinput
    else main
    fi

  fi
}

setupLXC(){
  if [ $L = "cn" ];then
    if (whiptail --title "LXC CentOS 7.9 授权服务器" --yes-button "继续" --no-button "返回"  --yesno "
      默认虚拟机配置：2CPU 2G
      默认IP地址：192.168.1.6
      默认访问网址：http://192.168.1.6:8080/licserver/
      默认终端登陆用户：root 密码：abc12345

      运行后注意事项：
      1）请在PVE网页端修改IP地址为你局域网的网段
      2）运行登陆后务必输入passwd修改默认密码
      3）第一次启动速度较慢，请耐心等待CPU占用接近0时再访问网址
      4）默认开机不启动，但强烈推荐设置VM为开机自启
      5）如遇无法下载，请手动百度云：
      https://pan.baidu.com/s/15TYh5PDfqmcEgwoDEv0aQQ 提取码：rldj
      下载完手动上传到/var/lib/vz/dump/里，注意下载的文件不要重命名！
      上传完毕后，重新运行此脚本即可
      " 23 80) then

      vmid=$(whiptail --inputbox "请输入授权服务器的虚拟机ID，默认是100" 8 60 100 --title "输入VM的ID值" 3>&1 1>&2 2>&3)
      exitstatus=$?
      if [ $exitstatus = 0 ]; then
          if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then typeuuid
          else 
          whiptail --title "Warnning" --msgbox "请重新输入100-999范围内的数字！" 10 60
          setupLXC
          fi
      fi

      if [ ! -f "/var/lib/vz/dump/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz" ];then
        echo "$(tput setaf 1)远程下载中，文件较大请耐心等候...$(tput setaf 0)"
        # $(tput setaf 0)wget https://github.com/kevinshane/unlock/raw/master/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz -P /var/lib/vz/dump/
        pip3 install gdown
        gdown https://drive.google.com/uc?id=11xQe_9F_8zKX3WEqE-oq9EnmpdUkWhSU -O /var/lib/vz/dump/
        
        pct restore $vmid local:backup/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz --storage local-lvm --unique 1 --memory 2048 --cores 2
        echo "$(tput setaf 2)搞定，请移步PVE网页端查看！$(tput setaf 0)"
      else
        pct restore $vmid local:backup/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz --storage local-lvm --unique 1 --memory 2048 --cores 2
        echo "$(tput setaf 2)搞定，请移步PVE网页端查看！$(tput setaf 0)"
      fi

      else main
    fi
  else # EN
    if (whiptail --title "LXC CentOS 7.9 License Server" --yes-button "Continue" --no-button "Go Back"  --yesno "
    default VM settings: 2 vCPU + 2G ram
    default IP addr: 192.168.1.6
    default Webpage: http://192.168.1.6:8080/licserver/
    default login user: root / password: abc12345

    Notice:
    1) Go to PVE webgui, set IP addr to your local network IP range
    2) Please change root login password when first launch
    3) Slow on first launch, please be patient
    4) It's recommanded to set the VM start on PVE boots
    " 20 80) then

    vmid=$(whiptail --inputbox "What's the VM id you want to deploy license sever? default is 100" 8 60 100 --title "define VM ID" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if [ "$vmid" -le 999 -a "$vmid" -ge 100 ]; then typeuuid
        else 
        whiptail --title "Warnning" --msgbox "Invalid VM ID. Choose between 100-999!" 10 60
        setupLXC
        fi
    fi

    if [ ! -f "/var/lib/vz/dump/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz" ];then
      echo "$(tput setaf 1)backup not exist, downloading from google drive...$(tput setaf 0)"
      pip3 install gdown
      gdown https://drive.google.com/uc?id=11xQe_9F_8zKX3WEqE-oq9EnmpdUkWhSU -O /var/lib/vz/dump/
      
      pct restore $vmid local:backup/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz --storage local-lvm --unique 1 --memory 2048 --cores 2
      echo "$(tput setaf 2)Done! Please check webgui! $(tput setaf 0)"
    else
      pct restore $vmid local:backup/vzdump-lxc-104-2021_04_26-20_21_33.tar.gz --storage local-lvm --unique 1 --memory 2048 --cores 2
      echo "$(tput setaf 2)Done! Please check webgui! $(tput setaf 0)"
    fi

    else main
    fi
  fi
}

resetDefaultvGPU(){
  runReset(){
    echo "$(tput setaf 2)Start reset process... 正在重置...$(tput setaf 0)"
    sed -i '/vfio-pci,sysfsdev=/d' /etc/pve/qemu-server/*.conf
    sed -i '/mdev/d' /etc/pve/qemu-server/*.conf
    sed -i '/-uuid/d' /etc/pve/qemu-server/*.conf
    
    systemctl disable mdev-startup.service
    systemctl daemon-reload
    rm /etc/systemd/system/mdev-startup.service
    
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

    if [ ! `grep -E "mdev=" /etc/pve/qemu-server/*.conf|wc -l` = 0 ];then
      qm list|sed '1d'|awk '{print $1}'|while read line ; do mdevctl stop -u 00000000-0000-0000-0000-000000000$line; done
    fi

    echo "$(tput setaf 2)Done reset! All vGPU resources released! 初始化完成，所有vGPU资源均已释放完毕！$(tput setaf 0)"
  }

  if [ $L = "cn" ];then # CN
    if (whiptail --title "初始化状态" --yes-button "继续" --no-button "返回"  --yesno "
    初始化所有相关vGPU和Quadro设置，整个过程无需重启
    或者你希望重新设置切分，此脚本将恢复到最初状态

    1）释放所有mdev设备
    2）删除所有跟vGPU相关的自启动服务
    3）删除所有虚拟机conf跟vGPU相关的设置
    4）所有虚拟机将恢复成无显卡直通的初始化状态

    " 20 80) then runReset
    else main
    fi
  else # EN
    if (whiptail --title "Reset to default" --yes-button "Continue" --no-button "Go Back"  --yesno "
    Script will auto reset everthing related to vGPU/Quadro
    Script doesn't require reboot after reset process

    1) Release all mdev devices to default
    2) Delete all startup services
    3) Delete all vGPU related settings for all VM's conf
    4) All VM will reset to no-vGPU mode

    " 20 80) then runReset
    else main
    fi
  fi
}

realtimeHW(){
  memory=$(nvidia-smi --query-gpu=memory.total --format=csv | awk '/^memory/ {getline; print}' | awk '{print $1}')
  MaxMemClk=$(nvidia-smi -q -d CLOCK | grep Memory | sed -n '4p' | awk '{print $3}')
  MaxSMClk=$(nvidia-smi -q -d CLOCK | grep SM | sed -n '3p' | awk '{print $3}')

  if [[ $L = "cn" ]];then # CN
  while :; do
  echo "
  ======realtime=======
  $(nvidia-smi --query-gpu=gpu_name --format=csv | sed -n '2p')
  温度：$(nvidia-smi --query-gpu=temperature.gpu --format=csv | sed -n '2p')°C
  性能：$(nvidia-smi --query-gpu=pstate --format=csv | sed -n '2p')
  功耗：$(nvidia-smi --query-gpu=power.draw --format=csv | sed -n '2p')
  占用：$(nvidia-smi --query-gpu=utilization.gpu --format=csv | sed -n '2p')

  显存占用
  已用：$(nvidia-smi --query-gpu=memory.used --format=csv | sed -n '2p')
  空闲：$(nvidia-smi --query-gpu=memory.free --format=csv | sed -n '2p')

  实时频率
  核心：$(nvidia-smi --query-gpu=clocks.sm --format=csv | sed -n '2p') / $MaxSMClk MHz
  显存：$(nvidia-smi --query-gpu=clocks.mem --format=csv | sed -n '2p') / $MaxMemClk MHz
  图形：$(nvidia-smi --query-gpu=clocks.gr --format=csv | sed -n '2p') / $MaxSMClk MHz

  $(nvidia-smi --query-gpu=timestamp --format=csv | sed -n '2p')
  =========ksh========="
  sleep 2
  done

  else # EN

  while :; do
  echo "
  ======realtime=======
  $(nvidia-smi --query-gpu=gpu_name --format=csv | sed -n '2p')
  Temp:  $(nvidia-smi --query-gpu=temperature.gpu --format=csv | sed -n '2p')°C
  Perf:  $(nvidia-smi --query-gpu=pstate --format=csv | sed -n '2p')
  Power: $(nvidia-smi --query-gpu=power.draw --format=csv | sed -n '2p')
  Usage: $(nvidia-smi --query-gpu=utilization.gpu --format=csv | sed -n '2p')

  Vram Usage
  Use:   $(nvidia-smi --query-gpu=memory.used --format=csv | sed -n '2p')
  Free:  $(nvidia-smi --query-gpu=memory.free --format=csv | sed -n '2p')

  Realtime Clock Speed
  Core:  $(nvidia-smi --query-gpu=clocks.sm --format=csv | sed -n '2p') / $MaxSMClk MHz
  Mem:   $(nvidia-smi --query-gpu=clocks.mem --format=csv | sed -n '2p') / $MaxMemClk MHz
  Graph: $(nvidia-smi --query-gpu=clocks.gr --format=csv | sed -n '2p') / $MaxSMClk MHz

  $(nvidia-smi --query-gpu=timestamp --format=csv | sed -n '2p')
  =========ksh========="
  sleep 2
  done

  fi

}

checkNVlog(){
  whiptail --title "LOG" --scrolltext --msgbox "$(journalctl -r | grep -i nvidia)" 30 150
  main
}

# --------------------------------------------------------- end module function --------------------------------------------------------- #

main(){
  if (whiptail --title "Language 选择语言" --yes-button "中文" --no-button "English"  --yesno "Choose Language - 选择语言:" 10 60) then
        L="cn"
    else
        L="en"
  fi

  if [ $L = "cn" ];then
  OPTION=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.3 " --menu "
  新装PVE请先运行步骤a，b，c
  解锁成Quadro选d和e选项！解锁成vGPU选f和g选项！
  请勿同时混合使用这两种模式
  请依照顺序选择配置，回车执行：" 27 60 15 \
  "a" "更新系统" \
  "b" "解锁vGPU" \
  "c" "美化系统" \
  "d" "Quadro 切分(重切分)显存" \
  "e" "Quadro 添加到VM" \
  "f" "vGPU 添加到VM (需正版授权)" \
  "g" "vGPU 授权服务器部署" \
  "s" "查看当前状态" \
  "r" "初始化vGPU状态" \
  "t" "实时硬件状态" \
  "v" "查看日志" \
  "q" "退出程序" \
  3>&1 1>&2 2>&3)
  else
  OPTION=$(whiptail --title " vGPU Unlock Tools - Version : 0.0.3 " --menu "
  For fresh install PVE, run (a), (b), (c)first
  Unlock to Quadro choose (d) and (e)
  Unlock to vGPU choose (f) and (g)
  Do not mix unlock type when using
  Select options, enter to apply: " 28 60 15 \
  "a" "Update PVE" \
  "b" "Unlock vGPU" \
  "c" "Beautify PVE" \
  "d" "Change Quadro VRAM Size" \
  "e" "Deploy Quadro to VM" \
  "f" "Deploy vGPU to VM (licServer required)" \
  "g" "Setup vGPU Licese Server" \
  "s" "Current GPU Status" \
  "r" "Reset all vGPU to default" \
  "t" "Real time Hardware status" \
  "v" "Check log" \
  "q" "Quit" \
  3>&1 1>&2 2>&3)
  fi

  case "$OPTION" in
  a ) startUpdate;;
  b ) startUnlock;;
  c ) startBeautify;;
  d ) chVram;;
  e ) deployQuadro;;
  f ) deployvGPU;;
  g ) setupLXC;;
  s ) checkStatus;;
  r ) resetDefaultvGPU;;
  t ) realtimeHW;;
  v ) checkNVlog;;
  q ) tput sgr 0
      exit;;
  esac
  tput sgr 0
}

while getopts "t" opt; do
  case ${opt} in
    t ) 
      realtimeHW
      ;;
    \? )
      echo error "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
if [ "$opt" = "?" ]
  then main
fi