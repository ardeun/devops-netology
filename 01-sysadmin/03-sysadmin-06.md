### 1. Работа c HTTP через телнет.
- Подключитесь утилитой телнет к сайту stackoverflow.com
`telnet stackoverflow.com 80`
- отправьте HTTP запрос
```bash
GET /questions HTTP/1.0
HOST: stackoverflow.com
[press enter]
[press enter]
```
```sh
 HTTP/1.1 301 Moved Permanently
Connection: close
cache-control: no-cache, no-store, must-revalidate
location: https://stackoverflow.com/questions
x-request-guid: c69d1a05-20ea-4e3e-b11a-d1e41a2f2efd
feature-policy: microphone 'none'; speaker 'none'
content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com
Accept-Ranges: bytes
Date: Tue, 01 Mar 2022 07:21:43 GMT
Via: 1.1 varnish
X-Served-By: cache-hhn4022-HHN
X-Cache: MISS
X-Cache-Hits: 0
X-Timer: S1646119304.653814,VS0,VE155
Vary: Fastly-SSL
X-DNS-Prefetch-Control: off
Set-Cookie: prov=fa24b820-d53f-492c-1db3-69afb5b4f890; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

Connection to host lost.
```
код 301 - редирект с HTTP на HTTPS
### 2. Повторите задание 1 в браузере, используя консоль разработчика F12.
- откройте вкладку `Network`
- отправьте запрос http://stackoverflow.com
- найдите первый ответ HTTP сервера, откройте вкладку `Headers`
- укажите в ответе полученный HTTP код.
- проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?
- приложите скриншот консоли браузера в ответ.



 <a href="https://ibb.co/mRM0Zbz"><img src="https://i.ibb.co/dfztCjK/Screenshot5.png" alt="Screenshot5" border="0"></a>
 + первый ответ, код 301 переадресация, дольше всего выполнялся скрипт jquery.min.js 
### 3. Какой IP адрес у вас в интернете?
`46.46.148.66`
### 4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой `whois`
```sh
whois 46.46.148.66
descr:          JSC "RetnNet"
origin:         AS29470
```
### 5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой `traceroute`
```sh
traceroute -An 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  172.30.0.1 [*]  1.444 ms  1.746 ms  2.171 ms
 2  172.29.2.2 [*]  0.538 ms  0.423 ms  0.638 ms
 3  46.46.148.65 [AS29470]  3.924 ms  3.806 ms  3.696 ms
 4  87.245.232.205 [AS9002]  1.374 ms  4.181 ms  1.157 ms
 5  72.14.222.22 [AS15169]  1.922 ms  1.344 ms  1.701 ms
 6  108.170.250.51 [AS15169]  67.912 ms 108.170.250.113 [AS15169]  2.118 ms 108.170.250.66 [AS15169]  2.617 ms
 7  209.85.255.136 [AS15169]  18.007 ms  17.902 ms *
 8  209.85.254.20 [AS15169]  20.023 ms 74.125.253.109 [AS15169]  18.864 ms 216.239.57.222 [AS15169]  20.970 ms
 9  142.250.56.215 [AS15169]  20.269 ms 142.250.208.25 [AS15169]  18.834 ms 142.250.210.45 [AS15169]  18.848 ms
10  * * *
11  * * *
12  * * *
13  * * *
14  * * *
15  * * *
16  * * *
17  * * *
18  * * *
19  8.8.8.8 [AS15169]  17.801 ms *  18.823 ms

```
### 6. Повторите задание 5 в утилите `mtr`. На каком участке наибольшая задержка - delay?
```sh
                                                                       My traceroute  [v0.93]
vagrant (10.0.2.15)                                                                                                                         2022-03-01T12:36:47+0000
Keys:  Help   Display mode   Restart statistics   Order of fields   quit
                                                                                                                            Packets               Pings
 Host                                                                                                                     Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. AS???    10.0.2.2                                                                                                      0.0%    26    5.0   3.0   0.6   5.0   1.1
 2. AS???    172.30.0.1                                                                                                    0.0%    26    2.9   4.2   1.8  14.1   2.4
 3. AS???    172.29.2.2                                                                                                    0.0%    26    2.3   3.2   1.1   5.9   1.2
 4. AS29470  46.46.148.65                                                                                                  0.0%    26    2.5   5.3   1.5  30.7   5.9
 5. AS29470  46.46.128.44                                                                                                  0.0%    26    3.1   6.9   1.9  33.6   6.6
 6. AS15169  72.14.222.22                                                                                                  0.0%    26    3.2   4.4   1.9   9.1   2.1
 7. AS15169  108.170.250.34                                                                                                0.0%    26    4.4   4.6   2.7  11.5   1.9
 8. AS15169  142.251.49.24                                                                                                 0.0%    25   16.9  18.9  16.8  23.1   1.7
 9. AS15169  172.253.65.82                                                                                                 0.0%    25   16.2  20.9  16.2  55.6   8.9
10. AS15169  142.250.208.23                                                                                                0.0%    25   18.3  19.1  17.2  22.4   1.3
11. (waiting for reply)
12. (waiting for reply)
13. (waiting for reply)
14. (waiting for reply)
15. (waiting for reply)
16. (waiting for reply)
17. (waiting for reply)
18. AS15169  8.8.8.8                                                                                                      95.8%    25   19.1  19.1  19.1  19.1   0.0
```
наибольшая задержка на 9 прыжке.
### 7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой `dig`
```sh
dig +short NS dns.google
ns4.zdns.google.
ns2.zdns.google.
ns1.zdns.google.
ns3.zdns.google.
dig +short A dns.google
8.8.8.8
8.8.4.4
```
### 8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой `dig`
```sh
dig -x 8.8.8.8
8.8.8.8.in-addr.arpa.   14072   IN      PTR     dns.google.
```
```ch
dig -x 8.8.4.4
4.4.8.8.in-addr.arpa.   18901   IN      PTR     dns.google.
```

