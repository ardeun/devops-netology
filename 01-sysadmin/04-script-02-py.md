## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | выдаст ошибку, сложение числа со строкой |
| Как получить для переменной `c` значение 12?  | c = str(a) + b  |
| Как получить для переменной `c` значение 3?  | c = a + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os


dr = "~/devops-netology"
bash_command = ["cd "+dr, "git status "]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:', '')
        print(dr+ prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~/devops-netology$ ./script1.py
~/devops-netology   README.md
~/devops-netology   has_been_moved.txt
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys


dr = sys.argv[1]

bash_command = ["cd "+dr,  "git status "]
result = os.listdir(dr);

if result.__contains__(".git"):
    result_os = os.popen(' && '.join(bash_command)).read()
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:', '')
            print(dr+ prepare_result)
else:
    print("no git repository")
```

### Вывод скрипта при запуске при тестировании:
```
vagrant@vagrant:~/devops-netology$ ./script2.py /home/vagrant/devops-netology/
/home/vagrant/devops-netology/   README.md
/home/vagrant/devops-netology/   has_been_moved.txt
vagrant@vagrant:~/devops-netology$ ./script2.py /home
no git repository
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json

host_file = 'hosts.json'
names = ['drive.google.com', 'mail.google.com', 'google.com']

try:
    with open(host_file) as js_file:
        log_data = json.load(js_file)
except IOError:
    log_data = {}

for name_ip in names:
    ip_address = socket.gethostbyname(name_ip)
    if name_ip in log_data:
        old_ip = log_data[name_ip]
        if old_ip != ip_address:
            print('[ERROR] {} IP mismatch: {} - {}'.format(name_ip, old_ip, ip_address))
            
    print('{} - {}'.format(name_ip, ip_address))
    log_data[name_ip] = ip_address

with open(host_file, 'w') as js_out:
    json.dump(log_data, js_out, indent=2)

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 173.194.222.194
[ERROR] mail.google.com IP mismatch: 108.177.14.17 - 108.177.14.18
mail.google.com - 108.177.14.18
[ERROR] google.com IP mismatch: 173.194.222.113 - 64.233.165.113
google.com - 64.233.165.113

```
