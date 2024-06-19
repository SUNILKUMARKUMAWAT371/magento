#!/bin/bash
docker compose -f ./docker-compose.yaml up -d
echo "container deployment is successfully"
sleep 10
docker ps

## Installing or Update the packages using Composer install
docker exec -it -w /var/www/magento magento composer install


## Magento installing with the specified configuration options like DB, ElasticSearch.

if [ ! -f ./magento/app/etc/env.php ]; then
    echo "Magento is not installed. Proceeding with fresh installation..."
    docker exec -it -w /var/www/magento magento bin/magento setup:install \
                                                --base-url=http://localhost \
                                                --db-host=mysql \
                                                --db-name=magento \
                                                --db-user=magento \
                                                --db-password="magento@123" \
                                                --admin-firstname=Admin \
                                                --admin-lastname=User \
                                                --admin-email=admin@magento-dev.com \
                                                --admin-user=admin \
                                                --admin-password=magento@123 \
                                                --language=en_US \
                                                --currency=USD \
                                                --timezone=America/Chicago \
                                                --use-rewrites=1 \
                                                --search-engine=elasticsearch7 \
                                                --elasticsearch-host=elasticsearch \
                                                --elasticsearch-port=9200
    echo "Magento installation completed."
else
    echo "Magento is already installed. Skipping installation."
fi


## Configure Redis with Magento application for full page cache

if grep -q "'session'" ./magento/app/etc/env.php && grep -q "'redis'" ./magento/app/etc/env.php; 
then
        echo "Redis is already installed. Skipping Configured"
else 
        ## Configure Redis with Magento application for full page cache
        #docker exec -it -w /var/www/magento magento bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=redis --page-cache-redis-db =0 --no-interaction
        #docker exec -it -w /var/www/magento magento bin/magento setup:config:set --session-save=redis --session-save-redis-host=redis --session-save-redis-db=3 --no-interaction
        docker exec -it -w /var/www/magento magento bin/magento setup:config:set \
                                                    --cache-backend=redis \
                                                    --cache-backend-redis-server=redis \
                                                    --cache-backend-redis-port=6379 \
                                                    --cache-backend-redis-db=0 \
                                                    --cache-backend-redis-password= \
                                                    --session-save=redis \
                                                    --session-save-redis-host=redis \
                                                    --session-save-redis-port=6379 \
                                                    --session-save-redis-log-level=4 \
                                                    --session-save-redis-db=1 \
                                                    --session-save-redis-password= \
                                                    --page-cache=redis \
                                                    --page-cache-redis-server=redis \
                                                    --page-cache-redis-port=6379 \
                                                    --page-cache-redis-db=2 \
                                                    --page-cache-redis-password= \
                                                    --no-interaction

        echo "Configure Redis with Magento application for full page cache successfully......"

fi


## change Ownership to magento code repository
docker exec -it magento chown -R www-data:www-data /var/www/magento


## varnish full page Configuration with magento

varnish_status=$(docker exec -it -w /var/www/magento magento bin/magento config:show system/full_page_cache/caching_application | tr -d '\r' )

if [ "$varnish_status" == "2" ];
then 
        echo "Varnish is already installed. Skipping Configured......"
else

        ## varnish full page Configuration with magento
        docker exec -it -w /var/www/magento magento bin/magento config:set system/full_page_cache/caching_application 2
        docker exec -it -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_host magento
        docker exec -it -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_port 80
        docker exec -it -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/access_list 0.0.0.0
        docker exec -it -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/grace_period 300
        echo "Varnish Configured Successfully......"
fi



## Admin URI
docker exec -it -w /var/www/magento magento bin/magento info:adminuri
