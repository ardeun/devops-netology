# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её  
нужно прервать.  

Вы как инженер поддержки решили произвести данную операцию:

- напишите список операций, которые вы будете производить для остановки запроса пользователя

```text
найти opid операции с помощью db.currentOp() и принудительно его завершить с помощью db.killOp()
```

- предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

```text
- Можно попробовать установить ограничение времени исполнения операций с помощью maxTimeMS().
- Проанализировать работу БД и попробовать оптимизировать, добавить/удалить индексы, настроить шардинг и т.п.
- Проанализировать аппаратную часть, если потребуется добавить ресурсов RAM,CPU и.т.д, или даже перенести базу на другой сервер.
```

## Задача 2

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL.  
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса.  

При масштабировании сервиса до N реплик вы увидели, что:

- сначала рост отношения записанных значений к истекшим
- Redis блокирует операции записи

Как вы думаете, в чем может быть проблема?

```text
Скорее всего память переполнена истёкшими ключами, 
Redis работает в однопоточном режиме, поэтому блокирует другие операции до окончания очистки истёкших ключей. 
```

## Задача 3

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:

```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

Как вы думаете, почему это начало происходить и как локализовать проблему?

```text
- Возможно слишком объёмные запросы, данные не успевают передаться за отведённое время.
- Возможно по каким-то причинам, скорее всего из-за скорости интернета, клиент не успевает установить соединение.
- Возможно размер запроса превышает размер буфера сообщений.
```

Какие пути решения данной проблемы вы можете предложить?

```text
- Если проблема в объёмных запросах нужно увеличить значение net_read_timeout.
- Если проблема в плохом качестве соединении клиента с сервером нужно увеличить значение connect_timeout.
- Если проблема в недостаточном буфере сообщений нужно увеличить значение max_allowed_packet.
```

## Задача 4

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с  
большим объемом данных лучше, чем MySQL.

После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит?

```text
Postgres нехватает оперативной памяти.
```

Как бы вы решили данную проблему?

```text
- В Postgres есть параметры регулирующие использование памяти, с их помощью можно снизить затраты памяти, но это может повлиять на производительность.
max_connections
shared_buffer
work_mem
effective_cache_size
maintenance_work_mem

- Увеличить объём памяти доступный для использования Postgres.
```

---
