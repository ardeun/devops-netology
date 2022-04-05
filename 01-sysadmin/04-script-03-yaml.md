## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
```json
{ "info": "Sample JSON output from our service\t",
  "elements": [
    {
      "name": "first",
      "type": "server",
      "ip": "7175"
    },
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"
    }
  ]
}

```
## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json
import yaml

host_js = 'hosts.json'
host_yml = 'hosts.yml'
names = ['drive.google.com', 'mail.google.com', 'google.com']

try:
    with open(host_js) as js_file:
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

with open(host_js, 'w') as js_out:
    json.dump(log_data, js_out, indent=2)

with open(host_yml, 'w') as yml_out:
    yaml.dump(log_data, yml_out, explicit_start=True, explicit_end=True)

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 173.194.222.194
[ERROR] mail.google.com IP mismatch: 108.177.14.17 - 173.194.222.19
mail.google.com - 173.194.222.19
google.com - 64.233.165.139

```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "drive.google.com": "74.125.131.194",
  "mail.google.com": "108.177.14.19",
  "google.com": "173.194.222.102"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
drive.google.com: 74.125.131.194
google.com: 173.194.222.102
mail.google.com: 108.177.14.19
...

```

