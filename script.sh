#!/bin/bash
chown -R www-data:www-data /var/www/magento \
&& chmod -R 755 /var/www/magento \
&& cp -r /var/www/magento/magento2.conf /etc/nginx/sites-enabled/ \
&& rm -rf /etc/nginx/sites-enabled/default \
&& service php8.3-fpm start