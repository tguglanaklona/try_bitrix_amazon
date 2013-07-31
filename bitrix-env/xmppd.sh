#!/bin/bash
test `ps -ef | grep php | grep xmppd | wc -l` -lt 1 -a -e /home/bitrix/www/bitrix/modules/xmpp/xmppd.php && { su - bitrix -c "php -c /etc/php.ini -f /home/bitrix/www/bitrix/modules/xmpp/xmppd.php > /dev/null 2>&1 &" ; service stunnel restart ; }
