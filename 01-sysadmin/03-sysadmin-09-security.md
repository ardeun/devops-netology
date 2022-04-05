### 1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.
Установил
### 2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.
Установил
### 3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.
```sh
vagrant@vagrant:~$ sudo apt install apache2
vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
vagrant@vagrant:~$ sudo vim /etc/apache2/conf-available/ssl-params.conf
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM
# Requires Apache 2.4.36 & OpenSSL 1.1.1
SSLProtocol -all +TLSv1.3 +TLSv1.2
SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1
# Older versions
# SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
SSLSessionTickets Off
```
```sh
vagrant@vagrant:~$ sudo vim /etc/apache2/sites-available/default-ssl.conf
<VirtualHost _default_:443>
                ServerAdmin webmaster@localhost
                ServerName 127.0.1.1

                DocumentRoot /var/www/html


                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined




                SSLEngine on

                SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
                SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>
```
```sh
vagrant@vagrant:~$ sudo vim /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        . . .

        Redirect permanent "/" "https://localhost/"

        . . .
</VirtualHost>
```
```sh
vagrant@vagrant:~$ sudo a2enmod ssl
vagrant@vagrant:~$ sudo a2enmod headers
vagrant@vagrant:~$ sudo a2ensite default-ssl
vagrant@vagrant:~$ sudo a2enconf ssl-params
vagrant@vagrant:~$ sudo apache2ctl configtest
vagrant@vagrant:~$ sudo systemctl restart apache2
```

### 4. Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).
```sh
vagrant@vagrant:~$ bash testssl.sh -p https://yandex.ru

###########################################################
    testssl.sh       3.1dev from https://testssl.sh/dev/
    (88cf7e6 2022-03-09 20:16:24 -- )

      This program is free software. Distribution and
             modification under GPLv2 permitted.
      USAGE w/o ANY WARRANTY. USE IT AT YOUR OWN RISK!

       Please file bugs @ https://testssl.sh/bugs/

###########################################################

 Using "OpenSSL 1.0.2-chacha (1.0.2k-dev)" [~183 ciphers]
 on haku-F7:./bin/openssl.Linux.x86_64
 (built: "Jan 18 17:12:17 2019", platform: "linux-x86_64")


Testing all IPv4 addresses (port 443): 77.88.55.77 77.88.55.80 5.255.255.5 5.255.255.60
-------------------------------------------------------------------------------------------------
 Start 2022-03-14 22:56:37        -->> 77.88.55.77:443 (yandex.ru) <<--

 Further IP addresses:   5.255.255.60 5.255.255.5 77.88.55.80 2a02:6b8:a::a 
 rDNS (77.88.55.77):     yandex.ru.
 Service detected:       HTTP


 Testing protocols via sockets except NPN+ALPN 

 SSLv2      not offered (OK)
 SSLv3      not offered (OK)
 TLS 1      offered (deprecated)
 TLS 1.1    offered (deprecated)
 TLS 1.2    offered (OK)
 TLS 1.3    offered (OK): final
 NPN/SPDY   not offered
 ALPN/HTTP2 h2, http/1.1 (offered)
 ```
### 5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.
```sh
vagrant@vagrant:~$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/vagrant/.ssh/id_rsa
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:fQbtAjglANlsOlxpy7w9hdAar53rcVqMTsxb4E9XUCI vagrant@vagrant
The key's randomart image is:
+---[RSA 3072]----+
|  .=.+. E . .    |
|  . X .+ . +     |
| . B *o.. o .    |
|  + = o..o +     |
|   . =.oS o =    |
|    o+=+   =     |
|      Bo* .      |
|     o.X .       |
|     .= .        |
+----[SHA256]-----+
vagrant@vagrant:~$ ssh-copy-id -i .ssh/id_rsa vagrant@192.168.199.13
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: ".ssh/id_rsa.pub"
The authenticity of host '192.168.199.13 (192.168.199.13)' can't be established.
ECDSA key fingerprint is SHA256:RztZ38lZsUpiN3mQrXHa6qtsUgsttBXWJibL2nAiwdQ.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter     out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompt    ed now it is to install the new keys
vagrant@192.168.199.13's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@192.168.199.13'"
and check to make sure that only the key(s) you wanted were added.
vagrant@vagrant:~$ ssh vagrant@192.168.199.13
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)
```
### 6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.
```sh
vagrant@vagrant:~$ vim ~/.ssh/config
Host vagrant2
        HostName 192.168.199.13
        User vagrant
        Port 22
        IdentityFile ~/.ssh/id_rsa
vagrant@vagrant:~$ ssh vagrant2
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)
```

### 7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.
```sh
vagrant@vagrant:~$ sudo tcpdump -i eth0 -c 100 -w dump.pcap
```
