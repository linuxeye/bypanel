### README.md
* [<a href="README-CN.md">中文</a>]
* [<a href="README.md">English</a>]

### 支持操作系统版本
* CentOS
* RedHat
* Alpine Linux
* Debian
* Ubuntu
* AlmaLinux
* Rocky Linux
* Fedora
* Amazon Linux
* Alibaba Linux
* Oracle Linux
* Arch Linux
* openSUSE
* Anolis
* OpencloudOS
* TencentOS
* EulerOS
* openEuler
* Kylin
* LinuxMint
* Elementary
* Deepin
* Kali Linux
* KylinsecOS
* Uos

### 安装
```
curl https://raw.githubusercontent.com/linuxeye/bypanel/main/quick_install.sh | bash
```
> 默认安装路径: `/opt/bypanel`
>
> bypctl安装路径: `/usr/local/bin/bypctl`

### 配置
```
bypctl config
```
配置部署bypanel参数，即修改`/opt/bypanel/.env`

### 命令帮助
```
bypctl help
```

### 创建和启动
```
bypctl up -d
```
创建和启动容器, 其中`-d`参数: 容器后台运行

### 生成web配置
```
bypctl mkcfg
```

### 重载web服务
```
bypctl reload
```

### 日志
```
bypctl logs -f
```
> 显示日志, 如显示nginx实时日志：`bypctl logs nginx -f `, 其中`-f`参数: 打印日志输出

### 服务状态
```
bypctl status
```
> 查看容器状态, 或执行命令 `bypctl ps` 作用相同

### 停止、删除容器和网络
```
bypctl down
```

### 重启服务
```
bypctl restart
```

### 启动服务
```
bypctl start
```

### 停止服务
```
bypctl stop
```

### 升级服务
```
bypctl upgrade
```

### 版本显示
```
bypctl version
```