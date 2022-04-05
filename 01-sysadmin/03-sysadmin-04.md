### 1.На лекции мы познакомились с `node_exporter` . В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой `unit-файл` для node_exporter:

```sh
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.0/node_exporter-1.3.0.linux-amd64.tar.gz
tar xzf node_exporter-1.3.0.linux-amd64.tar.gz
sudo cp node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo vim /etc/systemd/system/node_exporter.service
```

[Unit]  
Description=Node Exporter  
After=network-online.target

[Service]  
Type=simple  
ExecStart=/usr/local/bin/node_exporter $opts  
EnvironmentFile=-/usr/local/bin/node_exporter_opts  
Restart=on-failure  

[Install]  
WantedBy=multi-user.target

```sh
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter
● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2022-02-18 20:57:18 UTC; 25s ago
   Main PID: 1571 (node_exporter)
      Tasks: 4 (limit: 1071)
     Memory: 2.3M
     CGroup: /system.slice/node_exporter.service
             └─1571 /usr/local/bin/node_exporter
curl http://localhost:9100/metrics
```


### 2.Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
```sh
node_cpu_seconds_total{cpu="0",mode="idle"} 3338.34
node_cpu_seconds_total{cpu="0",mode="system"} 4.96
node_cpu_seconds_total{cpu="0",mode="user"} 2.04
node_cpu_seconds_total{cpu="1",mode="idle"} 3348.08
node_cpu_seconds_total{cpu="1",mode="system"} 4.69
node_cpu_seconds_total{cpu="1",mode="user"} 1.91

node_disk_io_time_seconds_total{device="sda"} 52.524
node_disk_read_bytes_total{device="sda"} 3.07120128e+08
node_disk_read_time_seconds_total{device="sda"} 90.043
node_disk_write_time_seconds_total{device="sda"} 79.8

node_memory_MemAvailable_bytes 7.22235392e+08
node_memory_MemFree_bytes 2.86908416e+08
node_memory_MemTotal_bytes 1.028685824e+09
node_memory_SwapFree_bytes 2.057302016e+09
node_memory_SwapTotal_bytes 2.057302016e+09

node_network_receive_bytes_total{device="eth0"} 4.9577196e+07
node_network_receive_drop_total{device="eth0"} 0
node_network_receive_errs_total{device="eth0"} 0
node_network_transmit_bytes_total{device="eth0"} 411012
node_network_transmit_drop_total{device="eth0"} 0
node_network_transmit_errs_total{device="eth0"} 0
```
### 3.Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (`sudo apt install -y netdata`). После успешной установки,зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам

<a href="https://ibb.co/PCQdR8t"><img src="https://i.ibb.co/q15vzwx/netdata.png" alt="netdata" border="0" /></a>

### 4.Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
да можно.
```sh
vagrant@vagrant:~$ dmesg |grep virtualiz
[    0.004941] CPU MTRRs all blank - virtualized system.
[    0.038408] Booting paravirtualized kernel on KVM
[    0.406562] Performance Events: PMU not available due to virtualization, using software events only.
[   13.725509] systemd[1]: Detected virtualization oracle.
```
### 5.Как настроен `sysctl fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

```sh
vagrant@vagrant:~$ sysctl fs.nr_open
fs.nr_open = 1048576
```
+ максимальное число открытых дискриптеров для ядра
```sh
vagrant@vagrant:~$ ulimit -n
1024
```
+ Soft limit для пользователя, может быть изменен

### 6.Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под `PID 1` через `nsenter`. Для простоты работайте в данном задании под `root` (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.
```sh
root@vagrant:~# unshare -f --pid --mount-proc sleep 1h
```
```sh
vagrant@vagrant:~$ ps -e | grep sleep
   1611 pts/0    00:00:00 sleep
vagrant@vagrant:~$ sudo nsenter --target 1611 --pid --mount
root@vagrant:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   5476   580 pts/0    S+   19:23   0:00 sleep 1h
root           2  0.0  0.4   7236  4272 pts/1    S    19:24   0:00 -bash
root          14  0.0  0.3   8892  3376 pts/1    R+   19:26   0:00 ps aux
``` 

### 7.Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?
команда является fork bomb, бесконечно создаёт свои копии

```
[ 1279.844406] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
```

+ срабатывает ограничение на запуск процессов
```sh
vagrant@vagrant:~$ cat /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.max
2356
```
+ максимальное число процессов по умолчанию

