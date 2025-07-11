# ByPanel

🌍 *[English](README.md) ∙ [简体中文](README-CN.md)*


### Support OS system
|             |            |               |            |            |
|:-----------:|:----------:|:-------------:|:----------:|:----------:|
| MacOS       | RedHat     | Alpine Linux  | Debian     | Ubuntu     |
| AlmaLinux   | Fedora     | Rocky Linux   | openSUSE   | Anolis     |
| OpencloudOS | TencentOS  | Amazon Linux  | EulerOS    | openEuler  |
| Kylin       | LinuxMint  | Alibaba Linux | Elementary | Uos        |
| Deepin      | KylinsecOS | Oracle Linux  | Kali Linux | Arch Linux |
| CentOS      | ...        |               |            |            |


### Install
```
curl -sSL https://mirrors.linuxeye.com/bypanel/quick_install.sh | bash
```

> Linux default install path: `/opt/bypanel`
>
> Linux bypanel binary path: `/usr/bin/bypanel`
>
> MacOS default install path: `$HOME/bypanel`
>
> MacOS bypanel binary path: `$HOME/bypanel/bin/bypanel`


bypanel binary download url(quick_install.sh has been automatically installed):
* Linux AMD64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-amd64
* Linux AArch64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-arm64
* MacOS AMD64: https://mirrors.linuxeye.com/bypanel/bypanel-darwin-amd64
* MacOS AArch64: https://mirrors.linuxeye.com/bypanel/bypanel-darwin-arm64


### Arch
![alt bypanel-arch](https://linuxeye.com/wp-content/uploads/2025/01/bypanel-arch.png)

### Help
```
bypanel help
```

### Configure
```
bypanel configure
```
Configuration of deployment parameters for bypanel
* Linux: `/opt/bypanel/.env`
* MacOS: `~/bypanel/.env`

### Configure
**Global Configuration File**: Lowest priority
```
bypanel configure
```
Configure deployment parameters for bypanel, which modifies the global configuration file

* Linux: `/opt/bypanel/.env`
* MacOS: `$HOME/bypanel/.env`

**Application Configuration File**: Medium priority

* Linux: `/opt/bypanel/app/{AppName}/.env`
* MacOS: `$HOME/bypanel/app/{AppName}/.env`

**Application Version Configuration File**: Highest priority
* Linux: `/opt/bypanel/app/{AppName}/{AppVersion}/.env`
* MacOS: `$HOME/bypanel/app/{AppName}/{AppVersion}/.env`

When different configuration files exist, the configuration file with the highest priority will override the configuration file with the lowest priority. That is, the application version configuration file will override the application configuration file, and the application configuration file will override the global configuration file.

### Pull service images
```
bypanel pull
```

### Create and start
```
bypanel up -d
```
> Create and start containers, `-d`: Detached mode: Run containers in the background

### Execute a command in a running container
```
bypanel exec SERVICE COMMAND
```

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

## SSL Certificate Manager
#### Add
```
bypanel scm add
```
#### Delete
```
bypanel scm del
```
#### List
```
bypanel scm list
```

### Reload Web service
```
bypanel reload
```
> Reload Web service containers

### List images used
```
bypanel images
```

### Logs
```
bypanel logs
```
> View output from containers, `-f`: Follow log output

### Status
```
bypanel ps
```
> List containers, or `bypanel status`

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

### Version
```
bypanel version
```
