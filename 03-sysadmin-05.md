### 1. Узнайте о `sparse` (разряженных) файлах.
Узнал.
### 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?
не могут, т.к. являются ссылками на один и тот же объект, имеют одинаковый inode и соответственно данные о владельце и правах доступа.

### 3.Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile
```sh
vagrant@vagrant:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop /snap/core18/2128
loop1                       7:1    0 70.3M  1 loop /snap/lxd/21029
loop3                       7:3    0 55.5M  1 loop /snap/core18/2284
loop4                       7:4    0 43.6M  1 loop /snap/snapd/14978
loop5                       7:5    0 61.9M  1 loop /snap/core20/1328
loop6                       7:6    0 67.2M  1 loop /snap/lxd/21835
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part /boot
└─sda3                      8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
sdc                         8:32   0  2.5G  0 disk
```

### 4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
```sh
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xc5ca0877.

Command (m for help): F
Unpartitioned space /dev/sdb: 2.51 GiB, 2683305984 bytes, 5240832 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes

Start     End Sectors  Size
 2048 5242879 5240832  2.5G

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
### 5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
```sh
root@vagrant:~# sfdisk -d /dev/sdb | sfdisk --force /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0xc5ca0877.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xc5ca0877

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

### 6. Соберите `mdadm` `RAID1` на паре разделов 2 Гб.
```sh
root@vagrant:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/{sdb,sdc}1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
### 7. Соберите `mdadm` `RAID0` на второй паре маленьких разделов.
```sh
root@vagrant:~# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/{sdb,sdc}2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```
### 8. Создайте 2 независимых `PV` на получившихся md-устройствах.
```sh
root@vagrant:~# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:~# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
```
### 9. Создайте общую `volume-group` на этих двух `PV`.
```sh
root@vagrant:~# vgcreate testvg /dev/md0 /dev/md1
  Volume group "testvg" successfully created
```
```sh
root@vagrant:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  testvg      2   0   0 wz--n-  <2.99g  <2.99g
  ubuntu-vg   1   1   0 wz--n- <63.00g <31.50g
```
### 10. Создайте `LV` размером 100 Мб, указав его расположение на `PV` с `RAID0`.
```sh
root@vagrant:~# lvcreate -L 100m -n test-lv testvg /dev/md1
  Logical volume "test-lv" created.
```
```sh
root@vagrant:~# lvs -o +devices
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  test-lv   testvg    -wi-a----- 100.00m                                                     /dev/md1(0)
  ubuntu-lv ubuntu-vg -wi-ao----  31.50g                                                     /dev/sda3(0)
  ```
### 11. Создайте `mkfs.ext4` ФС на получившемся `LV`.
```sh
root@vagrant:~# mkfs.ext4 /dev/testvg/test-lv
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

### 12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
```sh
root@vagrant:~# mkdir /tmp/new
root@vagrant:~# mount /dev/testvg/test-lv /tmp/new/
```
### 13. Поместите туда тестовый файл, например wget `https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
```sh
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-02-24 13:34:45--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22378087 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                          100%[==================================================================================>]  21.34M  10.6MB/s    in 2.0s

2022-02-24 13:34:47 (10.6 MB/s) - ‘/tmp/new/test.gz’ saved [22378087/22378087]
```
### 14. Прикрепите вывод `lsblk`.
```sh
root@vagrant:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 55.4M  1 loop  /snap/core18/2128
loop2                       7:2    0 61.9M  1 loop  /snap/core20/1361
loop3                       7:3    0 55.5M  1 loop  /snap/core18/2284
loop4                       7:4    0 43.6M  1 loop  /snap/snapd/14978
loop5                       7:5    0 61.9M  1 loop  /snap/core20/1328
loop6                       7:6    0 67.2M  1 loop  /snap/lxd/21835
loop7                       7:7    0 67.9M  1 loop  /snap/lxd/22526
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    1G  0 part  /boot
└─sda3                      8:3    0   63G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 31.5G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─testvg-test--lv     253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md0                     9:0    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md1                     9:1    0 1018M  0 raid0
    └─testvg-test--lv     253:1    0  100M  0 lvm   /tmp/new
```
### 15. Протестируйте целостность файла:
```sh
root@vagrant:~# gzip -t /tmp/new/test.gz && echo $?
0
```
### 16. Используя `pvmove`, переместите содержимое `PV` с `RAID0` на `RAID1`.
```sh
root@vagrant:~# pvmove -n test-lv /dev/md1 /dev/md0
  /dev/md1: Moved: 20.00%
  /dev/md1: Moved: 100.00%
```

### 17. Сделайте `--fail` на устройство в вашем `RAID1` `md`.
```sh
root@vagrant:~# mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```
### 18. Подтвердите выводом `dmesg`, что `RAID1` работает в деградированном состоянии.
```sh
root@vagrant:~# dmesg | grep md0
[73902.291882] md/raid1:md0: not clean -- starting background reconstruction
[73902.291884] md/raid1:md0: active with 2 out of 2 mirrors
[73902.293189] md0: detected capacity change from 0 to 2144337920
[73902.297642] md: resync of RAID array md0
[73913.109074] md: md0: resync done.
[269454.652853] md/raid1:md0: Disk failure on sdb1, disabling device.
                md/raid1:md0: Operation continuing on 1 devices.
```
### 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
```sh
root@vagrant:~# gzip -t /tmp/new/test.gz && echo $?
0
```
### 20. Погасите тестовый хост, `vagrant destroy`.
```sh
PS D:\VM\vagrant\project2> vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
```

