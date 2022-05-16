## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
```
Стандартизирует конфигурацию инфраструктуры, устраняет дрейф конфигурации, ускоряет обновления, исправления ошибок и восстановление системы,
упрощает развёртывание инфраструктуры, обеспечивает повторяемость.
```
- Какой из принципов IaaC является основополагающим?
```
Идемпотентность - принцип гарантирует, что при многократном выполнении операции мы получим идентичные результаты.
```

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
```
Прост в освоении, использует YAML для онисания конфигурации, не требует отдельного клиента т.к. использует ssh исфраструктуру.
```
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
```
на мой взгляд надёжнее push т.к. конфигурация обновляется сразу при изменении на управляющем сервере.
```
## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*
```sh
haku@haku-F7:~$ virtualbox -h
Oracle VM VirtualBox VM Selector v6.1.32_Ubuntu
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.
```
```sh
haku@haku-F7:~$ vagrant --version
Vagrant 2.2.6
```
```sh
haku@haku-F7:~$ ansible --version
ansible [core 2.12.4]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/haku/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/haku/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```
## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
