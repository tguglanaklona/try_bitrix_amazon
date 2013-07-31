#!/bin/bash
LOG_FILE=/home/bitrix/www/bitrix/modules/smtpd.log
if test `ps -ef | grep smtpd.php | grep -v grep |wc -l` -lt 1 -a -e /home/bitrix/www/bitrix/modules/mail/smtpd.php; then
        touch $LOG_FILE
        chown bitrix:bitrix $LOG_FILE > /dev/null 2>&1
        chmod o=rw,g=rw,u=rw $LOG_FILE > /dev/null 2>&1
        su - bitrix -c "authbind php -c /etc/php.ini -f /home/bitrix/www/bitrix/modules/mail/smtpd.php > /dev/null 2>&1 &"
fi
