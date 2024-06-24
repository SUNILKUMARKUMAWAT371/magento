#!/bin/bash

wget -qO- "https://github.com/magento/magento2/archive/refs/tags/2.4.7.tar.gz" | tar xz --strip-components=1 -C /var/www/magento \

#wget -qO- \"https://github.com/magento/magento2/archive/refs/tags/${magento_version}.tar.gz\" | tar xz --strip-components=1 -C /var/www/magento

# Change ownership and permissions
chown -R www-data:www-data /var/www/magento \

chmod -R 755 /var/www/magento \

# Copy the Magento Nginx configuration(virtualhosting)
cp -r /var/www/magento/magento2.conf /etc/nginx/sites-enabled/ \

# Remove the default Nginx configuration
rm -rf /etc/nginx/sites-enabled/default \

# Start the PHP-FPM service
service php8.3-fpm start