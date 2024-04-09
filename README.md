# bypanel

### Support OS system
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

### Clone bypanel
```
git clone https://github.com/linuxeye/bypanel.git
cd bypanel
cp env-example .env
```

### Edit .env
```
vi .env
```

### Install bypanel
```
./install.sh
```

### Start bypanel
```
docker-compose --profile nginx --profile php82 --profile mysql --profile phpmyadmin up -d

```

Start `nginx-1.24.0`, `php-8.2`, `maraidb-10.6`, `phpmyadmin` by default


### Stop bypanel
```
docker-compose --profile nginx --profile php82 --profile mysql --profile phpmyadmin stop
```
