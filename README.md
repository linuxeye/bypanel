# ByPanel

🌍 *[English](README.md) ∙ [简体中文](README-CN.md)*


### Support OS system
|             |            |               |            |            |
|:-----------:|:----------:|:-------------:|:----------:|:----------:|
| CentOS      | RedHat     | Alpine Linux  | Debian     | Ubuntu     |
| AlmaLinux   | Fedora     | Rocky Linux   | openSUSE   | Anolis     |
| OpencloudOS | TencentOS  | Amazon Linux  | EulerOS    | openEuler  |
| Kylin       | LinuxMint  | Alibaba Linux | Elementary | Uos        |
| Deepin      | KylinsecOS | Oracle Linux  | Kali Linux | Arch Linux |
| ...         |            |               |            |            |


### Install
```
curl -sSL https://mirrors.linuxeye.com/bypanel/quick_install.sh | bash
```
> Default install path: `/opt/bypanel`
>
> bypanel binary path: `/usr/bin/bypanel`

bypanel binary download url(quick_install.sh has been automatically installed):
* AMD64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-amd64
* AArch64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-arm64


### Help
```
bypanel help
```

### Configure
```
bypanel configure
```
> Configuration of deployment parameters for bypanel

### Create and start
```
bypanel up -d
```
> Create and start containers, `-d`: Detached mode: Run containers in the background

### Setting up virtual hosts on HTTP Server
#### Add
```
bypanel vhost add
```
#### Delete
```
bypanel vhost del
```
#### List
```
bypanel vhost list
```

### Logs
```
bypanel logs
```
> View output from containers, `-f`: Follow log output

### Status
```
bypanel status
```
> List containers, or `bypanel ps`

### Down
```
bypanel down
```
> Stop and remove containers, networks

### Restart
```
bypanel restart
```
> Restart service containers

### Start
```
bypanel start
```
> Start services containers

### Stop
```
bypanel stop
```
> Stop services containers

### Upgrade
```
bypanel upgrade
```
Upgrade bypctl to bypanel, execute `bypctl upgrade` twice
```
bypctl upgrade
bypctl upgrade
```

### Version
```
bypanel version
```
