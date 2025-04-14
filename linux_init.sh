#!/bin/bash

ZSH=/usr/share/oh-my-zsh
ZSH_CUSTOM=/usr/share/oh-my-zsh/custom
ZSH_THEME=risto
ZSH_UPDATE=disabled
ZDOTDIR=/etc/zsh

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release

    echo "OS: $NAME"
    echo "Version: $VERSION"
else
    echo "Unable to determine OS version. Exiting."
    exit 1
fi

read -p "This script will configure sudo without a password. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Sudo without password configuration skipped."
else
    echo "Sudo without password configuration started."

    echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo_nopasswd
    chmod 440 /etc/sudoers.d/sudo_nopasswd

    echo "Sudo without password configured."
fi

read -p "This script will configure the apt source to NJU mirror. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Apt source configuration skipped."
else
    echo "Apt source configuration started."
    # 如果系统是 debian
    if [[ "$ID" == "debian" ]]; then
        echo "Debian system detected."
        # 如果版本是 bullseye
        if [[ "$VERSION_ID" == "11" ]]; then
            echo "Debian 11 (Bullseye) detected."
            
            echo "deb https://mirror.nju.edu.cn/debian/ bullseye main contrib non-free" > /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://mirror.nju.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://mirror.nju.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye-backports main contrib non-free" >> /etc/apt/sources.list
            echo "deb https://mirrors.cernet.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list
        elif [[ "$VERSION_ID" == "12" ]]; then
            echo "Debian 12 (Bookworm) detected."

            echo "deb https://mirror.nju.edu.cn/debian/ bullseye main contrib non-free non-free-firmware" > /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb https://mirror.nju.edu.cn/debian/ bullseye-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb https://mirror.nju.edu.cn/debian/ bullseye-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb-src https://mirror.nju.edu.cn/debian/ bullseye-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb https://mirrors.cernet.edu.cn/debian-security bullseye-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/debian-security bullseye-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        else
            echo "Unsupported Debian version. Skipping apt source configuration."
        fi
    elif [[ "$ID" == "ubuntu" ]]; then
        echo "Ubuntu system detected."
        
        # 检查 VERSION_CODENAME 是否存在
        if [[ -n "$VERSION_CODENAME" ]]; then
            echo "Ubuntu version codename: $VERSION_CODENAME"

            echo "deb https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME main restricted universe multiverse" > /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-backports main restricted universe multiverse" >> /etc/apt/sources.list
            echo "deb-src https://mirrors.cernet.edu.cn/ubuntu/ $VERSION_CODENAME-backports main restricted universe multiverse" >> /etc/apt/sources.list
        else
            echo "VERSION_CODENAME not found. Skipping apt source configuration."
        fi

    fi

    apt update
fi

read -p "This script will configure the system language to Chinese. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "System language configuration skipped."
else
    echo "System language configuration started."
    # Configure system language to Chinese
    sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    update-locale LANG=zh_CN.UTF-8
    echo "LANG=zh_CN.UTF-8" > /etc/default/locale
    echo "System language configured to Chinese."
fi

read -p "This script will configure the system timezone to Asia/Shanghai. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "System timezone configuration skipped."
else
    echo "System timezone configuration started."
    # Configure system timezone to Asia/Shanghai
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
    echo "System timezone configured to Asia/Shanghai."
fi

read -p "This script will update the system and install some packages. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "System update and package installation skipped."
else
    echo "System update and package installation started."
    # Update the system and install some packages
    apt update
    apt upgrade -y
    apt install -y zsh htop rsync git
    apt autoremove -y
    echo "System update and package installation completed."
fi

read -p "This script will install Oh My Zsh. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Oh My Zsh installation skipped."
else
    echo "Oh My Zsh installation started."
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://install.ohmyz.sh/install.sh)" "$ZSH"

    chmod -R 755 "$ZSH"
    chmod -R 777 "$ZDOTDIR"
    echo "export ZSH=$ZSH" >> /etc/zsh/zshenv
    echo "export ZSH_CUSTOM=$ZSH_CUSTOM" >> /etc/zsh/zshenv
    echo "export ZDOTDIR=$ZDOTDIR" >> /etc/zsh/zshenv

    sed -i "s/plugins=(\(.*\))/plugins=(\1 colorize command-not-found common-aliases cp debian dotenv history zsh-history-substring-search sudo git-auto-fetch jump screen ssh docker docker-compose)/" "$ZDOTDIR/.zshrc"
    echo "alias cat='ccat'\nalias less='cless'" >> "$ZDOTDIR/.zshrc"
    echo "alias cp='cpv'" >> "$ZDOTDIR/.zshrc"

    apt install -y python3-pygments

    sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"$ZSH_THEME\"/" "$ZDOTDIR/.zshrc"
    sed -i "/^# zstyle ':omz:update' mode disabled/s/^# //g" "$ZDOTDIR/.zshrc"

    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/" "$ZDOTDIR/.zshrc"

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/" "$ZDOTDIR/.zshrc"

    git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
    sed -i "/source \$ZSH\/oh-my-zsh.sh/i fpath+=\$ZSH_CUSTOM/plugins/zsh-completions/src" "$ZDOTDIR/.zshrc"

    git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search
    sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-history-substring-search)/" "$ZDOTDIR/.zshrc"
fi

read -p "This script will configure zram. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Zram configuration skipped."
else
    echo "Zram configuration started."
    # Configure zram
    apt install -y zram-tools
    echo -e "ALGO=lz4\nPERCENT=200" | tee -a /etc/default/zramswap
    service zramswap reload
    echo "Zram configured."
fi

read -p "This script will configure swap. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Swap configuration skipped."
else
    echo "Swap configuration started."
    # Configure swap
    # 询问swap大小
    read -p "Enter swap size in MB (default: 2048): " swap_size
    swap_size=${swap_size:-2048}

    dd if=/dev/zero of=/swapfile bs=1M count=$swap_size
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
   
   
    echo "Swap configured."
fi

read -p "This script will install docker. Do you want to continue? (y/n): " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Docker installation skipped."
else
    echo "Docker installation started."
    # Install Docker
    apt-get update
    apt-get install ca-certificates curl -y
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirror.ccs.tencentyun.com/docker-ce/linux/ubuntu/ \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable --now docker
fi