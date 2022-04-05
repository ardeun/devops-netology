### 1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP
```
telnet route-views.routeviews.org
Username: rviews
show ip route x.x.x.x/32
show bgp x.x.x.x/32
```
```sh
route-views>show ip route 46.46.148.66
Routing entry for 46.46.128.0/18
  Known via "bgp 6447", distance 20, metric 0
  Tag 3356, type external
  Last update from 4.68.4.46 5d06h ago
  Routing Descriptor Blocks:
  * 4.68.4.46, from 4.68.4.46, 5d06h ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 3356
      MPLS label: none
route-views>show bgp 46.46.148.66
BGP routing table entry for 46.46.128.0/18, version 330971091
Paths: (23 available, best #11, table default)
  Not advertised to any peer
  Refresh Epoch 1
  3333 9002 29470
    193.0.0.56 from 193.0.0.56 (193.0.0.56)
      Origin IGP, localpref 100, valid, external
      path 7FE18D245F90 RPKI State valid
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  101 3356 9002 29470
    209.124.176.223 from 209.124.176.223 (209.124.176.223)
      Origin IGP, localpref 100, valid, external
      Community: 101:20100 101:20110 101:22100 3356:2 3356:22 3356:100 3356:123 3356:503 3356:901 3356:2067
      Extended Community: RT:101:22100
      path 7FE0F6F00588 RPKI State valid
      rx pathid: 0, tx pathid: 0
```
### 2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.
```sh
root@vagrant:~# ip link add dummy0 type dummy
root@vagrant:~# ip addr add 10.1.1.1/24 dev dummy0
root@vagrant:~# ip link set dummy0 up
root@vagrant:~# ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             10.0.2.15/24 fe80::a00:27ff:feb1:285d/64
dummy0           UNKNOWN        10.1.1.1/24 fe80::e085:5dff:feff:326c/64
root@vagrant:~# ip route add 8.8.8.8 via 10.1.1.1
root@vagrant:~# ip route add 8.8.8.0 via 10.0.2.15
root@vagrant:~# ip route
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100
8.8.8.0 via 10.0.2.15 dev eth0
8.8.8.8 via 10.1.1.1 dev dummy0
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
10.1.1.0/24 dev dummy0 proto kernel scope link src 10.1.1.1
```
### 3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.
```sh
root@vagrant:~# ss -tnlp
State        Recv-Q       Send-Q             Local Address:Port               Peer Address:Port       Process
LISTEN       0            4096               127.0.0.53%lo:53                      0.0.0.0:*           users:(("systemd-resolve",pid=599,fd=13))
LISTEN       0            128                      0.0.0.0:22                      0.0.0.0:*           users:(("sshd",pid=668,fd=3))
LISTEN       0            128                         [::]:22                         [::]:*           users:(("sshd",pid=668,fd=4))
```
53- DnS

22-ssh

### 4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?
```sh
root@vagrant:~# ss -unap
State        Recv-Q       Send-Q              Local Address:Port              Peer Address:Port       Process
UNCONN       0            0                   127.0.0.53%lo:53                     0.0.0.0:*           users:(("systemd-resolve",pid=599,fd=12))
UNCONN       0            0                  10.0.2.15%eth0:68                     0.0.0.0:*           users:(("systemd-network",pid=597,fd=15))
```
53-DNS

68-BOOTPC (Bootstrap Protocol Client)

### 5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали. 
<a href="https://ibb.co/LJMvGRK"><img src="https://i.ibb.co/Yy6brQg/net.png" alt="net" border="0"></a><br />
