# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению

1. (Необязательно) Познакомтесь с [lighthouse](https://youtu.be/ymlrNlaHzIY?t=929)
2. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.

Ссылка на репозиторий [LightHouse:](https://github.com/VKCOM/lighthouse)

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает lighthouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику lighthouse, установить nginx или любой другой webserver, настроить его конфиг для открытия lighthouse, запустить webserver.
4. Приготовьте свой собственный inventory файл `prod.yml`.

    [prod](./playbook/inventory/prod.yml)

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

    ```sh
    haku@ntb:~/devops-netology/mnt-homeworks/08-ansible-03-yandex/playbook$ ansible-lint site.yml 
    WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml

    Passed with production profile: 0 failure(s), 0 warning(s) on 1 files.
    ```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

    ```sh
    haku@ntb:~/devops-netology/mnt-homeworks/08-ansible-03-yandex/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check

    PLAY [Install Nginx] ********************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install epel-release] *************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install Nginx] ********************************************************************************************************************************************************************************
    changed: [lighthouse-01]

    TASK [Create Nginx config] **************************************************************************************************************************************************************************
    changed: [lighthouse-01]

    RUNNING HANDLER [Start nginx] ***********************************************************************************************************************************************************************
    skipping: [lighthouse-01]

    RUNNING HANDLER [Reload-nginx] **********************************************************************************************************************************************************************
    skipping: [lighthouse-01]

    PLAY [Install lighthouse] ***************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install git] **********************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Create Lighthouse config] *********************************************************************************************************************************************************************
    changed: [lighthouse-01]

    TASK [Copy Lighthouse from git] *********************************************************************************************************************************************************************
    changed: [lighthouse-01]

    RUNNING HANDLER [Reload-nginx] **********************************************************************************************************************************************************************
    skipping: [lighthouse-01]

    PLAY RECAP ******************************************************************************************************************************************************************************************
    lighthouse-01              : ok=8    changed=4    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
    ```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

    ```sh
    haku@ntb:~/devops-netology/mnt-homeworks/08-ansible-03-yandex/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff

    PLAY [Install Nginx] ********************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install epel-release] *************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install Nginx] ********************************************************************************************************************************************************************************
    changed: [lighthouse-01]

    TASK [Create Nginx config] **************************************************************************************************************************************************************************
    --- before: /etc/nginx/nginx.conf
    +++ after: /home/haku/.ansible/tmp/ansible-local-14967t4ax_jv9/tmp36tru76s/nginx.conf.j2
    @@ -1,13 +1,9 @@
    -# For more information on configuration, see:
    -#   * Official English Documentation: http://nginx.org/en/docs/
    -#   * Official Russian Documentation: http://nginx.org/ru/docs/
    +user root;
    +worker_processes 1;
    
    -user nginx;
    -worker_processes auto;
    error_log /var/log/nginx/error.log;
    pid /run/nginx.pid;
    
    -# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
    include /usr/share/nginx/modules/*.conf;
    
    events {
    @@ -30,55 +26,23 @@
        include             /etc/nginx/mime.types;
        default_type        application/octet-stream;
    
    -    # Load modular configuration files from the /etc/nginx/conf.d directory.
    -    # See http://nginx.org/en/docs/ngx_core_module.html#include
    -    # for more information.
        include /etc/nginx/conf.d/*.conf;
    
        server {
    -        listen       80;
    +       listen       80;
            listen       [::]:80;
            server_name  _;
            root         /usr/share/nginx/html;
    
    -        # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;
    
            error_page 404 /404.html;
            location = /404.html {
            }
    
    -        error_page 500 502 503 504 /50x.html;
    +       error_page 500 502 503 504 /50x.html;
            location = /50x.html {
            }
        }
    
    -# Settings for a TLS enabled server.
    -#
    -#    server {
    -#        listen       443 ssl http2;
    -#        listen       [::]:443 ssl http2;
    -#        server_name  _;
    -#        root         /usr/share/nginx/html;
    -#
    -#        ssl_certificate "/etc/pki/nginx/server.crt";
    -#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
    -#        ssl_session_cache shared:SSL:1m;
    -#        ssl_session_timeout  10m;
    -#        ssl_ciphers HIGH:!aNULL:!MD5;
    -#        ssl_prefer_server_ciphers on;
    -#
    -#        # Load configuration files for the default server block.
    -#        include /etc/nginx/default.d/*.conf;
    -#
    -#        error_page 404 /404.html;
    -#            location = /40x.html {
    -#        }
    -#
    -#        error_page 500 502 503 504 /50x.html;
    -#            location = /50x.html {
    -#        }
    -#    }
    -
    -}
    -
    +}
    \ No newline at end of file

    changed: [lighthouse-01]

    RUNNING HANDLER [Start nginx] ***********************************************************************************************************************************************************************
    changed: [lighthouse-01]

    RUNNING HANDLER [Reload-nginx] **********************************************************************************************************************************************************************
    changed: [lighthouse-01]

    PLAY [Install lighthouse] ***************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install git] **********************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Create Lighthouse config] *********************************************************************************************************************************************************************
    --- before
    +++ after: /home/haku/.ansible/tmp/ansible-local-14967t4ax_jv9/tmpew0fdrkv/default.conf.j2
    @@ -0,0 +1,11 @@
    +server {
    +    listen       80;
    +    server_name  localhost
    +    
    +    access_log  /var/log/nginx lighthouse_access.log  main;
    +    
    +    location / {
    +        root   /home/haku/lighthouse;
    +        index  index.html;
    +    }
    +}
    \ No newline at end of file

    changed: [lighthouse-01]

    TASK [Copy Lighthouse from git] *********************************************************************************************************************************************************************
    >> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
    changed: [lighthouse-01]

    RUNNING HANDLER [Reload-nginx] **********************************************************************************************************************************************************************
    changed: [lighthouse-01]

    PLAY RECAP ******************************************************************************************************************************************************************************************
    lighthouse-01              : ok=11   changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

    ```sh
    haku@ntb:~/devops-netology/mnt-homeworks/08-ansible-03-yandex/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff

    PLAY [Install Nginx] ********************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install epel-release] *************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install Nginx] ********************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Create Nginx config] **************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    PLAY [Install lighthouse] ***************************************************************************************************************************************************************************

    TASK [Gathering Facts] ******************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Install git] **********************************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Create Lighthouse config] *********************************************************************************************************************************************************************
    ok: [lighthouse-01]

    TASK [Copy Lighthouse from git] *********************************************************************************************************************************************************************
    ok: [lighthouse-01]

    PLAY RECAP ******************************************************************************************************************************************************************************************
    lighthouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

    [README](./playbook/README.md)

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

    [playbook](./playbook/)

---
