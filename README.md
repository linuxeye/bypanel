### README.md
* [<a href="README-CN.md">中文</a>]
* [<a href="README.md">English</a>]

### bypctl
[<a href="https://github.com/linuxeye/bypctl">bypanel command control</a>]

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
curl https://raw.githubusercontent.com/linuxeye/bypanel/main/quick_install.sh | bash
```
> Default install path: `/opt/bypanel`
>
> bypctl install path: `/usr/local/bin/bypctl`

### Help
```
bypctl help
```

### Config
```
bypctl config
```
> Configuration of deployment parameters for bypanel

### Create and start
```
bypctl up -d
```
> Create and start containers, `-d`: Detached mode: Run containers in the background

### Make web config
```
bypctl mkcfg
```

### Reload web config
```
bypctl reload
```

### Logs
```
bypctl logs
```
> View output from containers, `-f`: Follow log output

### Status
```
bypctl status
```
> List containers, or `bypctl ps`

### Down
```
bypctl down
```
> Stop and remove containers, networks

### Restart
```
bypctl restart
```
> Restart service containers

### Start
```
bypctl start
```
> Start services containers

### Stop
```
bypctl stop
```
> Stop services containers

### Upgrade
```
bypctl upgrade
```

### Version
```
bypctl version
```
