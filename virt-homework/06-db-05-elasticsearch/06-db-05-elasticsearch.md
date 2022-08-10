# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:

- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:

- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:

- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

---

```dockerfile
FROM centos:7

RUN yum update -y &&\
    yum install wget -y && \
    yum install perl-Digest-SHA -y

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.3-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.3.3-linux-x86_64.tar.gz.sha512 && \ 
    tar -xzf elasticsearch-8.3.3-linux-x86_64.tar.gz && \
    mv elasticsearch-8.3.3  /usr/share/elasticsearch &&\
    rm elasticsearch-8.3.3-linux-x86_64.tar.gz


RUN adduser -m -u 1000 elasticsearch && \
    mkdir /var/lib/logs && \
    mkdir /var/lib/data && \
    mkdir /usr/share/elasticsearch/snapshots && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/logs && \
    chown -R elasticsearch:elasticsearch /var/lib/data

WORKDIR /usr/share/elasticsearch

COPY elasticsearch.yml config/

ENV PATH /usr/share/elasticsearch/bin:$PATH \
    ES_HOME="/usr/share/elasticsearch" \
    ES_PATH_CONF="/usr/share/elasticsearch/config"

EXPOSE 9200 9300

USER elasticsearch
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]

```

<https://hub.docker.com/r/ardeun/elasticsearch>

```json
sh-4.2$ curl -X GET 'localhost:9200/'
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "95byBpCvT8a2XzkwAWtPeg",
  "version" : {
    "number" : "8.3.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801fed82df74dbe537f89b71b098ccaff88d2c56",
    "build_date" : "2022-07-23T19:30:09.227964828Z",
    "build_snapshot" : false,
    "lucene_version" : "9.2.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

[Dockerfile](src/Dockerfile)

[elasticsearch.yml](src/elasticsearch.yml)

## Задача 2

В этом задании вы научитесь:

- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

### *Важно*

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

```sh
curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'

curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'

curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'

curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WmALRmDtSc6cfl-gkkuOQg   1   0         40            0     37.8mb         37.8mb
green  open   ind-1            m4yfZC46T8ieVauB-tL_9w   1   0          0            0       226b           226b
yellow open   ind-3            79Qxq6L3R1G9z4OVvmcNNg   4   2          0            0       226b           226b
yellow open   ind-2            JfiK2x4sQb6eckhQyBCZYg   2   1          0            0       452b           452b


curl -XGET localhost:9200/_cluster/health/?pretty=true
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}

curl -X DELETE 'http://localhost:9200/_all'
{"acknowledged":true}
```

- с состоянием yellow индексы для которых настроены реплики, так как в кластере только одна нода реплики делать некуда.

## Задача 3

В данном задании вы научитесь:

- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

---

```sh
sh-4.2$ curl -X PUT localhost:9200/_snapshot/netology_backup -H 'Content-Type: application/json' -d'
{
 "type": "fs",
 "settings": {
   "location": "backup_location"
 }
}'
{"acknowledged":true}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

---

```sh
sh-4.2$ curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d '
{
 "settings": {
   "index": {
     "number_of_replicas": 0,
     "number_of_shards": 1
   }
 }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
sh-4.2$ curl http://localhost:9200/_cat/indices
green open test HYKadprSQeepLJGYrCUPDw 1 0 0 0 225b 225b
```

```sh
sh-4.2$ curl -X PUT "localhost:9200/_snapshot/netology_backup/nl_snapshot?wait_for_completion=true&pretty"
```

```sh
sh-4.2$ ls -la ./snapshots/backup_location/
total 36
drwxr-xr-x 1 elasticsearch elasticsearch   176 Aug  2 20:06 .
drwxr-xr-x 1 elasticsearch elasticsearch    30 Aug  2 20:04 ..
-rw-r--r-- 1 elasticsearch elasticsearch   844 Aug  2 20:06 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Aug  2 20:06 index.latest
drwxr-xr-x 1 elasticsearch elasticsearch    88 Aug  2 20:06 indices
-rw-r--r-- 1 elasticsearch elasticsearch 18236 Aug  2 20:06 meta-7IuiJ04TTEW2k76B_tEDDw.dat
-rw-r--r-- 1 elasticsearch elasticsearch   352 Aug  2 20:06 snap-7IuiJ04TTEW2k76B_tEDDw.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

---

```sh
sh-4.2$ curl -X DELETE localhost:9200/test
{"acknowledged":true}
sh-4.2$ curl -X PUT localhost:9200/test-2 -H 'Content-Type: application/json' -d '
{
 "settings": {
   "index": {
     "number_of_replicas": 0,
     "number_of_shards": 1
    }
 }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}
sh-4.2$ curl http://localhost:9200/_cat/indices
green open test-2 P7l3LdrrQ4SS7dzRly3r-g 1 0 0 0 225b 225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

---

```sh
sh-4.2$ curl -X POST localhost:9200/_snapshot/netology_backup/nl_snapshot/_restore
{"accepted":true}
sh-4.2$ curl http://localhost:9200/_cat/indices
green open test   sGzGlxayR1O8DJMx1uRyFA 1 0 0 0 225b 225b
green open test-2 P7l3LdrrQ4SS7dzRly3r-g 1 0 0 0 225b 225b
```

Подсказки:

- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---
