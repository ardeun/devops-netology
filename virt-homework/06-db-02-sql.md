# Домашнее задание к занятию "6.2. SQL"


## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume,
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```
[version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: db1
    container_name: pg12
    volumes:
    - /home/haku/docker/postgreSQL/data:/var/lib/postgresql/data
    - /home/haku/docker/postgreSQL/backup:/var/lib/postgresql/backup
    ports:
    - "5432:5432"
    restart: always
```



## Задача 2

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

```sh
test_db=# \l+
                                                                          Список баз данных
    Имя    | Владелец | Кодировка | LC_COLLATE |  LC_CTYPE  |       Права доступа        | Размер  | Табл. пространство |                  Описание                  
-----------+----------+-----------+------------+------------+----------------------------+---------+--------------------+--------------------------------------------
 db1       | admin    | UTF8      | en_US.utf8 | en_US.utf8 |                            | 7969 kB | pg_default         |
 postgres  | admin    | UTF8      | en_US.utf8 | en_US.utf8 |                            | 7969 kB | pg_default         | default administrative connection database
 template0 | admin    | UTF8      | en_US.utf8 | en_US.utf8 | =c/admin                  +| 7825 kB | pg_default         | unmodifiable empty database
           |          |           |            |            | admin=CTc/admin            |         |                    |
 template1 | admin    | UTF8      | en_US.utf8 | en_US.utf8 | =c/admin                  +| 7825 kB | pg_default         | default template for new databases
           |          |           |            |            | admin=CTc/admin            |         |                    |
 test_db   | admin    | UTF8      | en_US.utf8 | en_US.utf8 | =Tc/admin                 +| 8121 kB | pg_default         |
           |          |           |            |            | admin=CTc/admin           +|         |                    |
           |          |           |            |            | "test-simple-user"=c/admin |         |                    |
(5 строк)

test_db=# \d+ orders
                                                                   Таблица "public.orders"
   Столбец    |        Тип        | Правило сортировки | Допустимость NULL |            По умолчанию            | Хранилище | Цель для статистики | Описание
--------------+-------------------+--------------------+-------------------+------------------------------------+-----------+---------------------+----------
 id           | integer           |                    | not null          | nextval('orders_id_seq'::regclass) | plain     |                     |
 наименование | character varying |                    |                   |                                    | extended  |                     |
 цена         | integer           |                    |                   |                                    | plain     |                     |
Индексы:
    "orders_pkey" PRIMARY KEY, btree (id)
Ссылки извне:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Метод доступа: heap


test_db=# \d+ clients
                                                                     Таблица "public.clients"
      Столбец      |        Тип        | Правило сортировки | Допустимость NULL |            По умолчанию             | Хранилище | Цель для статистики | Описание
-------------------+-------------------+--------------------+-------------------+-------------------------------------+-----------+---------------------+----------
 id                | integer           |                    | not null          | nextval('clients_id_seq'::regclass) | plain     |                     |
 фамилия           | character varying |                    |                   |                                     | extended  |                     |
 страна проживания | character varying |                    |                   |                                     | extended  |                     |
 заказ             | integer           |                    |                   |                                     | plain     |                     |
Индексы:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_страна проживания_idx" btree ("страна проживания")
Ограничения внешнего ключа:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Метод доступа: heap

test_db=# SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants WHERE table_name in ('clients','orders') order by 1,2,3;
     grantee      | table_name | privilege_type
------------------+------------+----------------
 admin            | clients    | DELETE
 admin            | clients    | INSERT
 admin            | clients    | REFERENCES
 admin            | clients    | SELECT
 admin            | clients    | TRIGGER
 admin            | clients    | TRUNCATE
 admin            | clients    | UPDATE
 admin            | orders     | DELETE
 admin            | orders     | INSERT
 admin            | orders     | REFERENCES
 admin            | orders     | SELECT
 admin            | orders     | TRIGGER
 admin            | orders     | TRUNCATE
 admin            | orders     | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(29 строк)

```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы
- приведите в ответе:
    - запросы
    - результаты их выполнения.

```sh
test_db=# INSERT INTO orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
INSERT 0 5
test_db=# SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Принтер      | 3000
  3 | Книга        |  500
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 строк)

test_db=# SELECT count(1) FROM orders;
 count
-------
     5
(1 строка)

test_db=# INSERT INTO clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Рони Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5
test_db=# SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |      
  2 | Петров Петр Петрович | Canada            |      
  3 | Иоганн Себастьян Бах | Japan             |      
  4 | Рони Джеймс Дио      | Russia            |      
  5 | Ritchie Blackmore    | Russia            |      
(5 строк)

test_db=# SELECT count(1) FROM clients;
 count
-------
     5
(1 строка)

```
## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

Подсказк - используйте директиву `UPDATE`.

```sh
test_db=# UPDATE clients SET "заказ" = 3 WHERE "фамилия" = 'Иванов Иван Иванович';
UPDATE 1
test_db=# UPDATE clients SET "заказ" = 4 WHERE "фамилия" = 'Петров Петр Петрович';
UPDATE 1
test_db=# UPDATE clients SET "заказ" = 5 WHERE "фамилия" = 'Иоганн Себастьян Бах';
UPDATE 1
test_db=# SELECT c.фамилия, o.наименование FROM clients c JOIN orders o ON o.id = c.заказ;
       фамилия        | наименование
----------------------+--------------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 строки)

```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```sh
test_db=# EXPLAIN SELECT c.фамилия, o.наименование FROM clients c JOIN orders o ON o.id = c.заказ;
                               QUERY PLAN                                
-------------------------------------------------------------------------
 Hash Join  (cost=37.00..57.24 rows=810 width=64)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..18.10 rows=810 width=36)
   ->  Hash  (cost=22.00..22.00 rows=1200 width=36)
         ->  Seq Scan on orders o  (cost=0.00..22.00 rows=1200 width=36)
(5 строк)

```
Для каждой строки по полю "заказ" будет проверено, соответствует ли она чему-то в кеше orders
если соответствия нет строка будет пропущена.
- cost - затраты процессорного времени на поиск первой записи и сбор всей выборки.
- rows - количество возвращаемых строк при выполнении операции.
- width - средний размер одной строки в байтах.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

---
