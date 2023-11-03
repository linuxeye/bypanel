# bypanel

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
docker-compose --profile lnmp up -d
```

Start `nginx-1.24.0`, `php-8.2`, `maraidb-10.6`, `phpmyadmin` by default


### Stop bypanel
```
docker-compose --profile lnmp stop
```
