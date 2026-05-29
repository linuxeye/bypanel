# ByPanel

🌍 *[English](README.md) ∙ [简体中文](README-CN.md)*

### 支持操作系统版本
|             |            |               |            |            |
|:-----------:|:----------:|:-------------:|:----------:|:----------:|
| MacOS       | RedHat     | Alpine Linux  | Debian     | Ubuntu     |
| AlmaLinux   | Fedora     | Rocky Linux   | openSUSE   | Anolis     |
| OpencloudOS | TencentOS  | Amazon Linux  | EulerOS    | openEuler  |
| Kylin       | LinuxMint  | Alibaba Linux | Elementary | Uos        |
| Deepin      | KylinsecOS | Oracle Linux  | Kali Linux | Arch Linux |
| CentOS      | ...        |               |            |            |


### 安装
```
bash -c "$(curl -sSL https://mirrors.linuxeye.com/bypanel/quick_install.sh)"
```

> Linux 默认安装路径: `/opt/bypanel`
>
> Linux bypanel二进制路径: `/usr/bin/bypanel`
>
> MacOS 默认安装路径: `$HOME/bypanel`
>
> MacOS bypanel二进制路径: `$HOME/bypanel/bin/bypanel`

bypanel二进制下载地址(quick_install.sh已自动安装)
* Linux AMD64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-amd64
* Linux AArch64: https://mirrors.linuxeye.com/bypanel/bypanel-linux-arm64
* MacOS AMD64: https://mirrors.linuxeye.com/bypanel/bypanel-darwin-amd64
* MacOS AArch64: https://mirrors.linuxeye.com/bypanel/bypanel-darwin-arm64

### 架构图
![alt bypanel-arch-cn](https://linuxeye.com/wp-content/uploads/2025/01/bypanel-arch-cn.png)


### 命令帮助
```
bypanel help
```

### 配置
**全局配置文件**: 优先级最低
```
bypanel configure
```
配置部署bypanel参数，即修改全局配置文件

* Linux: `/opt/bypanel/.env`
* MacOS: `$HOME/bypanel/.env`

**应用配置文件**: 优先级次之
* Linux: `/opt/bypanel/app/{AppName}/.env`
* MacOS: `$HOME/bypanel/app/{AppName}/.env`

**应用版本配置文件**: 优先级最高
* Linux: `/opt/bypanel/app/{AppName}/{AppVersion}/.env`
* MacOS: `$HOME/bypanel/app/{AppName}/{AppVersion}/.env`

当不同配置文件中存在相同变量时，高优先级的配置文件会覆盖低优先级的配置文件。即应用版本配置文件会覆盖应用配置文件，应用配置文件会覆盖全局配置文件。

### 镜像拉取
```
bypanel pull
```

### 创建和启动
```
bypanel up -d
```
创建和启动容器, 其中`-d`参数: 容器后台运行

### 在运行中容器执行命令
```
bypanel exec SERVICE COMMAND
```
### 站点根目录权限
```
sudo chown -R 1000:1000 /data/webroot
sudo find /data/webroot -type d -print0 | sudo xargs -0 chmod 755
sudo find /data/webroot -type f -print0 | sudo xargs -0 chmod 644
```

### 虚拟主机
#### 添加
```
bypanel vhost add
```
#### 删除
```
bypanel vhost del
```
#### 列表
```
bypanel vhost list
```

### SSL证书管理
#### 添加
```
bypanel scm add
```
#### 删除
```
bypanel scm del
```
#### 列表
```
bypanel scm list
```

### 重载web服务
```
bypanel reload
```

### 查看使用的镜像
```
bypanel images
```

### 日志
```
bypanel logs -f
```
> 显示日志, 如显示nginx实时日志：`bypanel logs nginx -f `, 其中`-f`参数: 打印日志输出

### 服务状态
```
bypanel ps
```
> 查看容器状态

### 停止、删除容器和网络
```
bypanel down
```

### 重启服务
```
bypanel restart
```

### 启动服务
```
bypanel start
```

### 停止服务
```
bypanel stop
```

### 升级命令
```
bypanel upgrade
```

### 版本显示
```
bypanel version
```

### 卸载
```
bash -c "$(curl -sSL https://mirrors.linuxeye.com/bypanel/uninstall.sh)"
```
