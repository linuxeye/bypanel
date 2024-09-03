# ByPanel

🌍 *[English](README.md) ∙ [简体中文](README-CN.md)*

### 支持操作系统版本
|             |            |               |            |            |
|:-----------:|:----------:|:-------------:|:----------:|:----------:|
| CentOS      | RedHat     | Alpine Linux  | Debian     | Ubuntu     |
| AlmaLinux   | Fedora     | Rocky Linux   | openSUSE   | Anolis     |
| OpencloudOS | TencentOS  | Amazon Linux  | EulerOS    | openEuler  |
| Kylin       | LinuxMint  | Alibaba Linux | Elementary | Uos        |
| Deepin      | KylinsecOS | Oracle Linux  | Kali Linux | Arch Linux |
| ...         |            |               |            |            |


### 安装
```
curl -sSL https://mirrors.linuxeye.com/bypanel/quick_install.sh | bash
```
> 默认安装路径: `/opt/bypanel`
>
> bypanel二进制路径: `/usr/bin/bypanel`

bypanel二进制下载地址
* AMD64: https://mirrors.linuxeye.com/bypanel/bypctl-linux-amd64
* AArch64: https://mirrors.linuxeye.com/bypanel/bypctl-linux-arm64

### 配置
```
bypanel configure
```
配置部署bypanel参数，即修改`/opt/bypanel/.env`

### 命令帮助
```
bypanel help
```

### 创建和启动
```
bypanel up -d
```
创建和启动容器, 其中`-d`参数: 容器后台运行

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

### 重载web服务
```
bypanel reload
```

### 日志
```
bypanel logs -f
```
> 显示日志, 如显示nginx实时日志：`bypanel logs nginx -f `, 其中`-f`参数: 打印日志输出

### 服务状态
```
bypanel status
```
> 查看容器状态, 或执行命令 `bypanel ps` 作用相同

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
bypctl升级为bypanel, 2次执行`bypctl upgrade`
```
bypctl upgrade
bypctl upgrade
```

### 版本显示
```
bypanel version
```