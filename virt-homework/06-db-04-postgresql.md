# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

```sh
[haku@pc1 ~]$ docker run --rm --name pgsql_1 -e POSTGRES_PASSWORD=admin -p 5432:5432 -v v_pdsql:/var/lib/postgresql/data -d postgres:13
```
```sh
root@d3299f0a414a:/# psql -U postgres
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

postgres=#
```
- \l
- \c DBNAME
- \dt[S+]
- \d[S+] NAME
- \q


## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sh
[haku@pc1 docker]$ docker cp pgsql_test_dump.sql pgsql_1:/var/lib/postgresql
```
```sh
postgres=# create database test_database;
CREATE DATABASE
```
```sh
root@d3299f0a414a:/# psql -U postgres -f /var/lib/postgresql/pgsql_test_dump.sql  test_database

postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# analyze VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=# select avg_width from pg_stats where tablename='orders' ;
 avg_width
-----------
         4
        16
         4
(3 rows)

```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```sh
test_database=# create table orders_1 (check ( price > 499 )) inherits ( orders );
CREATE TABLE
test_database=# create table orders_2 (check ( price <= 499 )) inherits ( orders );
CREATE TABLE
test_database=# insert into orders_1 select * from orders where (price > 499);
INSERT 0 3
test_database=# insert into orders_2 select * from orders where (price <= 499);
INSERT 0 5

```
можно изначально настроить разбиение таблиц
```sh
create rule price_more_499 as on insert to orders where ( price > 499 ) do instead insert into orders_1 values (new.*);

create rule price_less_499 as on insert to orders where ( price <= 499 ) do instead insert into orders_2 values (new.*);
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```sh
root@d3299f0a414a:/# pg_dump -U postgres test_database > /var/lib/postgresql/test_database_dump.sql
```
```sh
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);

```
---
