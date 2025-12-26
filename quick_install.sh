#!/bin/sh
# Author:  Justo <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: ByPanel for Linux/Darwin 64bit
#
# Project home page:
#       https://github.com/linuxeye/bypanel

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/homebrew/bin:$PATH

AUTO_SWAP=${AUTO_SWAP:-0}
DOCKER_VERSION=${DOCKER_VERSION:-"29.1.3"}
DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-"5.0.1"}
MIRROR_URL=${MIRROR_URL:-http://mirrors.linuxeye.com}
KERNEL_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
IP_COUNTRY=$(curl -s ipinfo.io/country)

case "${KERNEL_NAME}" in
darwin*)
  NEW_UID=${NEW_UID:-$(id -u)}
  NEW_GID=${NEW_GID:-$(id -g)}
  BASE_PATH=${BASE_PATH:-$HOME/bypanel}
  VOLUME_PATH=${VOLUME_PATH:-$HOME/bypanel/data}
  BYPANEL_PATH=${BYPANEL_PATH:-$HOME/bypanel/bin/bypanel}
  ;;
*)
  NEW_UID=${NEW_UID:-1000}
  NEW_GID=${NEW_GID:-1000}
  BASE_PATH=${BASE_PATH:-/opt/bypanel}
  VOLUME_PATH=${VOLUME_PATH:-/data}
  BYPANEL_PATH=${BYPANEL_PATH:-/usr/bin/bypanel}
  # Check if user is root
  [ $(id -u) != "0" ] && {
    printf "\033[31mError: You must be root to run this script\033[0m\n"
    exit 1
  }
  ;;
esac

case "${ARCH}" in
x86_64)
  BYPANEL_BIN=bypanel-${KERNEL_NAME}-amd64
  ;;
aarch64 | arm64)
  BYPANEL_BIN=bypanel-${KERNEL_NAME}-arm64
  ;;
armv7l)
  ARCH="armv7"
  ;;
*)
  printf "\033[31mERROR: Unsupported operating system '${KERNEL_NAME}' \033[0m\n"
  exit 1
  ;;
esac

download_bypanel() {
  [ ! -d ${BASE_PATH}/bin ] && mkdir -p ${BASE_PATH}/bin
  if [ ! -e ${BASE_PATH}/env-example ]; then
    printf "\033[33mDownloading bypanel.tar.gz... \033[0m\n"
    [ -e /tmp/bypanel.tar.gz ] && rm -rf /tmp/{bypanel.tar.gz,bypanel}
    curl -L -# ${MIRROR_URL}/bypanel.tar.gz -o /tmp/bypanel.tar.gz 2>&1
    LOCAL_PANEL_MD5=$(md5sum /tmp/bypanel.tar.gz | awk '{print $1}')
    REMOTE_PANEL_MD5=$(curl --connect-timeout 3 -m 5 -s ${MIRROR_URL}/md5sum.txt | grep bypanel.tar.gz | awk '{print $1}')
    if [ "${LOCAL_PANEL_MD5}" != "${REMOTE_PANEL_MD5}" ]; then
      printf "\033[31mError: bypanel.tar.gz package md5 error! \033[0m\n"
      exit 1
    fi
    tar xzf /tmp/bypanel.tar.gz -C /tmp/
    /bin/mv /tmp/bypanel/* ${BASE_PATH}/
    rm -f /tmp/bypanel.tar.gz
  else
    printf "\033[33m${BASE_PATH} is already installed! \033[0m\n"
  fi

  if [ ! -e ${BYPANEL_PATH} ]; then
    printf "\033[33mDownloading ${BYPANEL_PATH}... \033[0m\n"
    curl -L -# ${MIRROR_URL}/bypanel/${BYPANEL_BIN} -o ${BYPANEL_PATH}
    chmod +x ${BYPANEL_PATH}
  else
    printf "\033[33m${BYPANEL_PATH} is already installed! \033[0m\n"
    printf "\033[33mYou can upgrade by running the command \`bypanel upgrade\`! \033[0m\n"
  fi
}

setup_bypanel_env() {
  if [ ! -e ${BASE_PATH}/.env ]; then
    /bin/cp ${BASE_PATH}/env-example ${BASE_PATH}/.env
    case "${KERNEL_NAME}" in
    darwin*)
      sed -i '' "s@^BASE_PATH=.*@BASE_PATH=${BASE_PATH}@" ${BASE_PATH}/.env
      sed -i '' "s@^VOLUME_PATH=.*@VOLUME_PATH=${VOLUME_PATH}@" ${BASE_PATH}/.env
      sed -i '' "s@^NEW_UID=.*@NEW_UID=${NEW_UID}@" ${BASE_PATH}/.env
      sed -i '' "s@^NEW_GID=.*@NEW_GID=${NEW_GID}@" ${BASE_PATH}/.env
      if ! grep -q bypanel ~/.zshrc; then
        echo "export PATH=\"$HOME/bypanel/bin:\$PATH\"" >>~/.zshrc
        source ~/.zshrc
      fi
      ;;
    *)
      sed -i "s@^BASE_PATH=.*@BASE_PATH=${BASE_PATH}@" ${BASE_PATH}/.env
      sed -i "s@^VOLUME_PATH=.*@VOLUME_PATH=${VOLUME_PATH}@" ${BASE_PATH}/.env
      sed -i "s@^NEW_UID=.*@NEW_UID=${NEW_UID}@" ${BASE_PATH}/.env
      sed -i "s@^NEW_GID=.*@NEW_GID=${NEW_GID}@" ${BASE_PATH}/.env
      ;;
    esac
  fi
}

start_bypanel_linux() {
  cat >/lib/systemd/system/bypanel.service <<EOF
[Unit]
Description=Systemd ByPanel
After=network.target

[Service]
# Execute \$(systemctl daemon-reload) after ExecStart= is changed.
ExecStart=${BYPANEL_PATH}

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable bypanel >/dev/null 2>&1
  systemctl start bypanel
  if [ $? -eq 0 ]; then
    printf "\033[32mbypanel installed successfully! \033[0m\n"
  else
    printf "\033[31mbypanel installation failed! \033[0m\n"
    exit 1
  fi

}

start_bypanel_darwin() {
  [ ! -e ~/Library/LaunchAgents/bypanel.plist ] && cat >~/Library/LaunchAgents/bypanel.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>bypanel</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/bypanel/bin/bypanel</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
  pgrep -q "bypanel" && launchctl unload ~/Library/LaunchAgents/bypanel.plist
  launchctl load ~/Library/LaunchAgents/bypanel.plist
  if [ $? -eq 0 ]; then
    printf "\033[32mbypanel installed successfully! \033[0m\n"
  else
    printf "\033[31mbypanel installation failed! \033[0m\n"
    exit 1
  fi
}

setup_system_linux() {
  if [ -e "/etc/os-release" ]; then
    . /etc/os-release
  else
    printf "\033[31m/etc/os-release does not exist! \033[0m\n"
    exit 1
  fi
  PLATFORM=$(printf "${ID}" | tr '[:upper:]' '[:lower:]')
  PLATFORM_RHEL="centos rhel almalinux rocky fedora amzn ol alinux anolis tencentos opencloudos hce openeuler kylin uos kylinsecos"
  PLATFORM_DEBIAN="debian deepin kali"
  PLATFORM_UBUNTU="ubuntu linuxmint elementary"
  if [ "${PLATFORM}" = "alpine" ]; then
    # Custom profile
    cat >/etc/profile.d/bypanel.sh <<EOF
HISTSIZE=10000
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\\\$ "
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt'
alias lh='l | head'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF
    # /etc/sysctl.conf
    [ -z "$(grep 'fs.file-max' /etc/sysctl.conf)" ] && cat >>/etc/sysctl.conf <<EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
    sysctl -p >/dev/null
  elif [ -n "$(echo ${PLATFORM_RHEL} | grep -w ${PLATFORM})" ]; then
    # Close SELINUX
    [ -e "/etc/selinux/config" ] && sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
    command -v setenforce >/dev/null 2>&1 && setenforce 0

    # Custom profile
    cat >/etc/profile.d/bypanel.sh <<EOF
HISTSIZE=10000
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\\\$ "
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt'
alias lh='l | head'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF
    PLATFORM_EULER="hce openeuler"
    [ -n "$(echo ${PLATFORM_EULER} | grep -w ${PLATFORM})" ] && sed -i '/HISTTIMEFORMAT=/d' /etc/profile.d/bypanel.sh

    [ -z "$(echo ${PLATFORM_EULER} | grep -w ${PLATFORM})" ] && [ -z "$(grep ^'PROMPT_COMMAND=' /etc/bashrc)" ] && cat >>/etc/bashrc <<EOF
PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "[euid=\$(whoami)]":\$(who am i):[\`pwd\`]"\$msg"; }'
EOF

    # /etc/security/limits.conf
    [ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
    sed -i '/^# End of file/,$d' /etc/security/limits.conf
    cat >>/etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

    # ip_conntrack table full dropping packets
    if [ -d "/etc/sysconfig/modules" ]; then
      echo "modprobe nf_conntrack" >/etc/sysconfig/modules/nf_conntrack.modules
      chmod +x /etc/sysconfig/modules/nf_conntrack.modules
    fi
    modprobe nf_conntrack
    echo options nf_conntrack hashsize=131072 >/etc/modprobe.d/nf_conntrack.conf

    # /etc/sysctl.conf
    [ ! -e "/etc/sysctl.conf_bk" ] && /bin/mv /etc/sysctl.conf /etc/sysctl.conf_bk
    cat >/etc/sysctl.conf <<EOF
fs.file-max=1000000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.tcp_max_syn_backlog = 16384
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_syncookies = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.ip_local_port_range = 1024 65000
net.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
EOF
    sysctl -p >/dev/null
  elif [ -n "$(echo ${PLATFORM_DEBIAN} | grep -w ${PLATFORM})" ]; then
    # Custom profile
    cat >/etc/profile.d/bypanel.sh <<EOF
HISTSIZE=10000
PS1='\${debian_chroot:+(\$debian_chroot)}\\[\\e[1;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt --color=auto'
alias lh='l | head'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF

    sed -i 's@^"syntax on@syntax on@' /etc/vim/vimrc

    # history
    [ -z "$(grep history-timestamp ~/.bashrc)" ] && echo "PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >>~/.bashrc

    # /etc/security/limits.conf
    [ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
    [ -z "$(grep 'session required pam_limits.so' /etc/pam.d/common-session)" ] && echo "session required pam_limits.so" >>/etc/pam.d/common-session
    sed -i '/^# End of file/,$d' /etc/security/limits.conf
    cat >>/etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
root soft nproc 1000000
root hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

    # /etc/sysctl.conf
    [ -z "$(grep 'fs.file-max' /etc/sysctl.conf)" ] && cat >>/etc/sysctl.conf <<EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
    sysctl -p >/dev/null
  elif [ -n "$(echo ${PLATFORM_UBUNTU} | grep -w ${PLATFORM})" ]; then
    # Custom profile
    cat >/etc/profile.d/bypanel.sh <<EOF
HISTSIZE=10000
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt --color=auto'
alias lh='l | head'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF

    sed -i 's@^"syntax on@syntax on@' /etc/vim/vimrc

    # PS1
    [ -z "$(grep ^PS1 ~/.bashrc)" ] && echo "PS1='\${debian_chroot:+(\$debian_chroot)}\\[\\e[1;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '" >>~/.bashrc

    # history
    [ -z "$(grep history-timestamp ~/.bashrc)" ] && echo "PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >>~/.bashrc

    # /etc/security/limits.conf
    [ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
    [ -z "$(grep 'session required pam_limits.so' /etc/pam.d/common-session)" ] && echo "session required pam_limits.so" >>/etc/pam.d/common-session
    sed -i '/^# End of file/,$d' /etc/security/limits.conf
    cat >>/etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
root soft nproc 1000000
root hard nproc 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF

    # /etc/sysctl.conf
    [ -z "$(grep 'fs.file-max' /etc/sysctl.conf)" ] && cat >>/etc/sysctl.conf <<EOF
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
    sysctl -p >/dev/null

    sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES="/dev/tty[1-2]"@' /etc/default/console-setup
  fi
}

install_docker_linux() {
  if command -v docker >/dev/null 2>&1; then
    printf "Docker is already installed, skip...\n"
    printf "Start Docker...\n"
    if command -v systemctl >/dev/null 2>&1; then
      systemctl enable docker >/dev/null 2>&1
      systemctl start docker >/dev/null 2>&1
    else
      service docker start >/dev/null 2>&1
    fi
  else
    printf "Install Docker...\n"
    if [ "${PLATFORM}" = "alpine" ]; then
      apk update
      apk add docker docker-cli-compose
      rc-update add docker default
    elif [ "${PLATFORM}" = "arch" ]; then
      pacman -S docker docker-compose --noconfirm
    elif [ "${PLATFORM}" = "opensuse-leap" ]; then
      zypper --non-interactive install docker docker-compose
    elif [ "${PLATFORM}" = "amzn" ]; then
      yum -y install docker
    elif [ "${PLATFORM}" = "almalinux" ] || [ "${PLATFORM}" = "rocky" ] || [ "${PLATFORM}" = "ol" ] || [ "${PLATFORM}" = "anolis" ] || [ "${PLATFORM}" = "opencloudos" ]; then
      if [ "${IP_COUNTRY}x" = "CN"x ]; then
        DOCKER_REPO_URL=https://mirrors.aliyun.com/docker-ce
        ALMA_REPO_URL=https://mirrors.aliyun.com/almalinux
      else
        DOCKER_REPO_URL=https://download.docker.com
        ALMA_REPO_URL=https://repo.almalinux.org/almalinux
      fi
      if [ "${PLATFORM}" = "opencloudos" ] && [ "$(echo $VERSION_ID | cut -d'.' -f1)" = '9' ]; then
        yum install -y ${ALMA_REPO_URL}/9/AppStream/x86_64/os/Packages/container-selinux-2.229.0-1.el9_3.noarch.rpm
      fi
      cat >/etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=${DOCKER_REPO_URL}/linux/rhel/\$releasever/\$basearch/stable
enabled=1
gpgcheck=0
EOF
      yum clean all
      yum -y install docker-ce
    elif [ "${PLATFORM}" = "alinux" ] || [ "${PLATFORM}" = "tencentos" ]; then
      VERSION_ID=$(echo $VERSION_ID | cut -d'.' -f1)
      if [ "${VERSION_ID}" = "4" ]; then
        releasever=9
      elif [ "${VERSION_ID}" = "3" ]; then
        releasever=8
      elif [ "${VERSION_ID}" = "2" ]; then
        releasever=7
      fi
      [ "${IP_COUNTRY}x" = "CN"x ] && DOCKER_REPO_URL=https://mirrors.aliyun.com/docker-ce || DOCKER_REPO_URL=https://download.docker.com
      cat >/etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=${DOCKER_REPO_URL}/linux/rhel/$releasever/\$basearch/stable
enabled=1
gpgcheck=0
EOF
      yum clean all
      yum -y install docker-ce
    else
      printf "\033[33mDownloading get-docker.sh... \033[0m\n"
      if [ "${IP_COUNTRY}x" = "CN"x ]; then
        curl -L -# https://ghfast.top/https://raw.githubusercontent.com/docker/docker-install/master/install.sh -o get-docker.sh 2>&1
      else
        curl -L -# https://get.docker.com -o get-docker.sh 2>&1
      fi

      if [ -e "get-docker.sh" ]; then
        if [ "${IP_COUNTRY}x" = "CN"x ]; then
          sh get-docker.sh --mirror Aliyun 2>&1
        else
          sh get-docker.sh 2>&1
        fi
        rm -f get-docker.sh
      else
        printf "\033[31mget-docker.sh download failed, will try to install docker using install-docker.sh \033[0m\n"
      fi
    fi

    if ! command -v docker >/dev/null 2>&1; then
      if [ "${IP_COUNTRY}x" = "CN"x ]; then
        curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh | bash -s docker --mirror aliyun --version ${DOCKER_VERSION} --with-compose --compose-version ${DOCKER_COMPOSE_VERSION} --compose-mirror daocloud --systemd-mirror "daocloud"
      else
        curl -fsSL https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh | bash -s docker --with-compose
      fi
    fi
    DOCKER_CONFIG_DIR="/etc/docker"
    [ ! -d "${DOCKER_CONFIG_DIR}" ] && mkdir "${DOCKER_CONFIG_DIR}"
    if [ "${IP_COUNTRY}x" = "CN"x ]; then
      IP_ORG=$(curl -s ipinfo.io/org)
      if echo ${IP_ORG} | grep -wiq Alibaba; then
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://u79eurfi.mirror.aliyuncs.com"
  ]
}
EOF
      elif echo ${IP_ORG} | grep -wiq Tencent; then
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.1ms.run"
  ]
}
EOF
      elif echo ${IP_ORG} | grep -wiq Huawei; then
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://44d8ee9edbbf4b07b9f0216b7a8fc0cc.mirror.swr.myhuaweicloud.com"
  ]
}
EOF
      else
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run"
  ]
}
EOF
      fi
    fi

    printf "Start Docker...\n"
    if command -v systemctl >/dev/null 2>&1; then
      systemctl enable docker
      systemctl daemon-reload
      systemctl restart docker >/dev/null 2>&1
    else
      service docker restart >/dev/null 2>&1
    fi

    if command -v docker >/dev/null 2>&1; then
      printf "\033[32mDocker installed successfully! \033[0m\n"
    else
      printf "\033[31mDocker installation failed! \033[0m\n"
      exit 1
    fi
  fi
}

install_docker_darwin() {
  if command -v docker >/dev/null 2>&1; then
    printf "Docker is already installed, skip...\n"
  else
    printf "Please Install Docker on MacOS, Installation documentation: https://docs.docker.com/desktop/setup/install/mac-install/"
  fi

  if [ "${IP_COUNTRY}x" = "CN"x ]; then
    [ -e ~/.docker/daemon.json ] && cat >~/.docker/daemon.json <<EOF
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://docker.1ms.run"
  ]
}
EOF
  fi

  if ! pgrep -q "Docker Desktop"; then
    open -g -a Docker
  fi

  if ! docker info >/dev/null 2>&1; then
    printf "\033[33mWarning: Docker service starts slowly, you may need to check manually \033[0m\n"
    exit 1
  fi
}

install_docker_compose_linux() {
  if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_MAIN_VER=$(docker-compose -v | awk '{print $NF}' | awk -F. '{print $1}')
    if [ ${DOCKER_COMPOSE_MAIN_VER#v} -ge 2 ]; then
      printf "Docker Compose is already installed, skip...\n"
    else
      while :; do
        echo
        read -e -p "The installed version of Docker Compose is too low. Do you want to upgrade it? [y/n] : " DOCKER_COMPOSE_UPGRADE_FLAG
        if [ "${DOCKER_COMPOSE_UPGRADE_FLAG}" != "y" -a "${DOCKER_COMPOSE_UPGRADE_FLAG}" != "n" ]; then
          printf "\033[33minput error! Please only input 'y' or 'n'\033[0m\n"
        else
          break
        fi
      done

      # upgrade docker componse
      if [ "${DOCKER_COMPOSE_UPGRADE_FLAG}" = "y" ]; then
        rm -f /usr/bin/docker-compose /usr/local/bin/docker-compose
        Install_Compose
      fi
    fi
  else
    if [ -e /usr/libexec/docker/cli-plugins/docker-compose ]; then
      [ ! -L /usr/bin/docker-compose ] && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
    else
      printf "Install Docker Compose...\n"
      DOCKER_COMPOSE_LATEST_VER=$(curl -s https://api.github.com/repos/docker/compose/tags | grep 'name' | cut -d\" -f4 | head -1)
      curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_LATEST_VER}/docker-compose-$(uname -s | tr A-Z a-z)-${ARCH} -o /usr/local/bin/docker-compose 2>&1
      if [ ! -e /usr/local/bin/docker-compose ]; then
        printf "\033[31mdocker-compose download failed, please try again \033[0m\n"
        exit 1
      fi
      chmod +x /usr/local/bin/docker-compose
      [ ! -L /usr/bin/docker-compose ] && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    if command -v docker-compose >/dev/null 2>&1; then
      printf "\033[32mDocker Compose installed successfully! \033[0m\n"
    else
      printf "\033[31mDocker Compose installation failed! \033[0m\n"
      exit 1
    fi
  fi
  docker-compose version
}

install_docker_compose_darwin() {
  if ! command -v brew >/dev/null 2>&1; then
    printf "\033[33mCommand 'brew' not found, Installation documentation: https://brew.sh\033[0m\n"
    exit 1
  fi

  if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_MAIN_VER=$(docker-compose -v | awk '{print $NF}' | awk -F. '{print $1}')
    if [ ${DOCKER_COMPOSE_MAIN_VER#v} -ge 2 ]; then
      printf "Docker Compose is already installed, skip...\n"
    fi
  else
    printf "Install Docker Compose...\n"
    brew install docker-compose
    if ! command -v docker-compose >/dev/null 2>&1; then
      printf "\033[31m'brew install docker-compose' failed, please try again \033[0m\n"
      exit 1
    fi
    chmod +x /usr/local/bin/docker-compose

    if command -v docker-compose >/dev/null 2>&1; then
      printf "\033[32mDocker Compose installed successfully! \033[0m\n"
    else
      printf "\033[31mDocker Compose installation failed! \033[0m\n"
      exit 1
    fi
  fi
  docker-compose version
}

setup_webroot() {
  mkdir -p ${VOLUME_PATH}/webroot/default
  echo "<?php phpinfo() ?>" >${VOLUME_PATH}/webroot/default/phpinfo.php
  curl -fsSL "${MIRROR_URL}/bypanel/demo.html" -o ${VOLUME_PATH}/webroot/default/index.html 2>&1
  curl -fsSL "${MIRROR_URL}/bypanel/xprober.php" -o ${VOLUME_PATH}/webroot/default/xprober.php 2>&1
  chown -R ${NEW_UID}:${NEW_GID} ${VOLUME_PATH}/webroot
}

setup_swap() {
  if [ "${AUTO_SWAP}" = "1" ]; then
    printf "Setup swap...\n"
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    printf "/swapfile none swap sw 0 0\n" | sudo tee -a /etc/fstab
  fi
}

main() {
  download_bypanel
  setup_bypanel_env
  case "${KERNEL_NAME}" in
  darwin*)
    install_docker_darwin
    install_docker_compose_darwin
    setup_webroot
    start_bypanel_darwin
    ;;
  *)
    setup_swap
    setup_system_linux
    install_docker_linux
    install_docker_compose_linux
    setup_webroot
    start_bypanel_linux
    ;;
  esac
}

main
