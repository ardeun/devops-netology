# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

   ```text
   playbook/group_vars/all/examp.yml
   ```

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

   ```text
   ansible-playbook site.yml -i inventory/test.yml
   ```

3. Какой командой можно зашифровать файл?

   ```text
   ansible-vault encrypt
   ```

4. Какой командой можно расшифровать файл?

   ```text
   ansible-vault decrypt
   ```

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

   ```text
   ansible-vault view
   ```

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

   ```text
   ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
   ```

7. Как называется модуль подключения к host на windows?

   ```text
   ansible_connection: winrm
   ```

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

   ```text
   ansible-doc -t connection ssh
   ```

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

    ```text
    remote_user
    ```
