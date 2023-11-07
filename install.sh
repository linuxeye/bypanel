#!/bin/sh
# Author:  Justo <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: ByPanel for Linux 64bit
#
# Project home page:
#       https://bypanel.com
#       https://github.com/bypanel/bypanel

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#                     ByPanel for Linux 64bit                         #
#       For more information please visit https://linuxeye.com        #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && {
  echo -e "\033[31mError: You must be root to run this script\033[0m"
  exit 1
}

CURRENT_DIR=$(dirname "$(readlink -f $0)")

Check_Env() {
  if [ ! -e ${CURRENT_DIR}/.env ]; then
    echo -e "\033[31m${CURRENT_DIR}/.env does not exist! \033[0m"
    echo -e "You can execute the command: 'cp ${CURRENT_DIR}/env-example ${CURRENT_DIR}/.env'"
    echo -e "'vi ${CURRENT_DIR}/.env', Change to the configuration you want"
    exit 1
  fi
}

Init_OS() {
  if [ -e "/etc/os-release" ]; then
    . /etc/os-release
  else
    echo -e "\033[31m/etc/os-release does not exist! \033[0m"
    exit 1
  fi
  PLATFORM=$(printf "$ID" | tr '[:upper:]' '[:lower:]')
  if [[ "${PLATFORM}" =~ ^alpine$ ]]; then
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
  elif [[ "${PLATFORM}" =~ ^centos$|^rhel$|^almalinux$|^rocky$|^fedora$|^amzn$|^ol$|^alinux$|^anolis$|^tencentos$|^opencloudos$|^euleros$|^openeuler$|^kylin$|^uos$|^kylinsecos$ ]]; then
    # Close SELINUX
    sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
    setenforce 0

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
    [[ "${PLATFORM}" =~ ^euleros$|^openeuler$ ]] && sed -i '/HISTTIMEFORMAT=/d' /etc/profile.d/bypanel.sh

    [[ ! "${PLATFORM}" =~ ^euleros$|^openeuler$ ]] && [ -z "$(grep ^'PROMPT_COMMAND=' /etc/bashrc)" ] && cat >>/etc/bashrc <<EOF
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
    echo -e "modprobe nf_conntrack" >/etc/sysconfig/modules/nf_conntrack.modules
    chmod +x /etc/sysconfig/modules/nf_conntrack.modules
    modprobe nf_conntrack
    echo options nf_conntrack hashsize=131072 >/etc/modprobe.d/nf_conntrack.conf

    # /etc/sysctl.conf
    [ ! -e "/etc/sysctl.conf_bk" ] && /bin/mv /etc/sysctl.conf{,_bk}
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
  elif [[ "${PLATFORM}" =~ ^debian$|^deepin$|^kali$ ]]; then
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
  elif [[ "${PLATFORM}" =~ ^ubuntu$|^linuxmint$|^elementary$ ]]; then
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

Install_Docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed, skip..."
    echo "Start Docker..."
    if command -v systemctl >/dev/null 2>&1; then
      systemctl enable docker >/dev/null 2>&1 | tee -a ${CURRENT_DIR}/install.log
      systemctl start docker >/dev/null 2>&1 | tee -a ${CURRENT_DIR}/install.log
    else
      service docker start >/dev/null 2>&1 | tee -a ${CURRENT_DIR}/install.log
    fi
  else
    echo "Install Docker..."
    if [[ "${PLATFORM}" =~ ^alpine$ ]]; then
      apk update
      apk add docker docker-cli-compose
      rc-update add docker default
    elif [[ "${PLATFORM}" =~ ^arch$ ]]; then
      pacman -S docker docker-compose --noconfirm
    elif [[ "${PLATFORM}" =~ ^amzn$ ]]; then
      yum -y install docker
    elif [[ "${PLATFORM}" =~ ^alinux$ ]]; then
      cat >/etc/yum.repos.d/docker-ce.repo <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
      yum clean all
      yum -y install docker-ce
    else
      curl -fsSL https://get.docker.com -o get-docker.sh 2>&1 | tee -a ${CURRENT_DIR}/install.log
      if [ ! -e "get-docker.sh" ]; then
        echo -e "\033[31mget-docker.sh download failed, please try again \033[0m"
        exit 1
      fi
      if [ "$(curl -s ipinfo.io/country)x" == "CN"x ]; then
        sh get-docker.sh --mirror Aliyun 2>&1 | tee -a ${CURRENT_DIR}/install.log
      else
        sh get-docker.sh 2>&1 | tee -a ${CURRENT_DIR}/install.log
      fi
      rm -f get-docker.sh
    fi

    DOCKER_CONFIG_DIR="/etc/docker"
    [ ! -d "${DOCKER_CONFIG_DIR}" ] && mkdir "${DOCKER_CONFIG_DIR}"
    [ "$(curl -s ipinfo.io/country)x" == "CN"x ] && cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://dockerproxy.com"
  ]
}
EOF

    echo "Start Docker..."
    if command -v systemctl >/dev/null 2>&1; then
      systemctl enable docker
      systemctl daemon-reload
      systemctl start docker >/dev/null 2>&1 | tee -a ${CURRENT_DIR}/install.log
    else
      service docker start >/dev/null 2>&1 | tee -a ${CURRENT_DIR}/install.log
    fi

    if command -v docker >/dev/null 2>&1; then
      echo -e "\033[32mDocker installed successfully! \033[0m"
    else
      echo -e "\033[31mDocker installation failed! \033[0m"
      exit 1
    fi
  fi
}

Install_Compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_COMPOSE_MAIN_VER=$(docker-compose -v | awk '{print $NF}' | awk -F. '{print $1}')
    if [[ ${DOCKER_COMPOSE_MAIN_VER#v} -ge 2 ]]; then
      echo "Docker Compose is already installed, skip..."
    else
      while :; do
        echo
        read -e -p "The installed version of Docker Compose is too low. Do you want to upgrade it? [y/n] : " DOCKER_COMPOSE_UPGRADE_FLAG
        if [[ ! ${DOCKER_COMPOSE_UPGRADE_FLAG} =~ ^[y,n]$ ]]; then
          echo -e "\033[33minput error! Please only input 'y' or 'n'\033[0m"
        else
          break
        fi
      done

      # upgrade docker componse
      if [ "${DOCKER_COMPOSE_UPGRADE_FLAG}" == "y" ]; then
        rm -f /usr/bin/docker-compose /usr/local/bin/docker-compose
        Install_Compose
      fi
    fi
  else
    if [ -e /usr/libexec/docker/cli-plugins/docker-compose ]; then
      [ ! -L /usr/bin/docker-compose ] && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose
    else
      echo "Install Docker Compose..."
      ARCH=$(uname -m)
      if [ "${ARCH}" == 'armv7l' ]; then
        ARCH='armv7'
      fi
      curl -L https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s | tr A-Z a-z)-${ARCH} -o /usr/local/bin/docker-compose 2>&1 | tee -a ${CURRENT_DIR}/install.log
      if [ ! -e /usr/local/bin/docker-compose ]; then
        echo -e "\033[31mdocker-compose download failed, please try again \033[0m"
        exit 1
      fi
      chmod +x /usr/local/bin/docker-compose
      [ ! -L /usr/bin/docker-compose ] && ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    if command -v docker-compose >/dev/null 2>&1; then
      echo -e "\033[32mDocker Compose installed successfully! \033[0m"
    else
      echo -e "\033[31mDocker Compose installation failed! \033[0m"
      exit 1
    fi
  fi
  docker-compose version
}

Init_Webroot() {
  . ${CURRENT_DIR}/.env
  mkdir -p ${BASE_DATA_PATH}/webroot/default
  echo "<?php phpinfo() ?>" >${BASE_DATA_PATH}/webroot/default/phpinfo.php
  curl -fsSL "https://api.inn-studio.com/download?id=xprober" -o ${BASE_DATA_PATH}/webroot/default/xprober.php 2>&1
  chown -R 1000:1000 ${BASE_DATA_PATH}/webroot
}

main() {
  Check_Env
  Init_OS
  Install_Docker
  Install_Compose
  Init_Webroot
}

main
