# copy files if they don't exist
copy_files() {
    if [ ! -f ./magento/magento2.conf ] && [ ! -f ./magento/script.sh ]; then
        cp -r magento2.conf magento/
        cp -r script.sh magento/
        echo "Magento virtual hosting and script.sh file copied successfully."
    else
        echo "Magento virtual hosting and script.sh already exist."
    fi  
}


# deploy Docker containers
deploy_containers() {
    docker compose -f ./docker-compose.yaml up -d
    if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
        echo "Container deployment was successful."
        #sleep 10
        docker ps
    else
        echo "Failed to deploy containers."
        exit 1
    fi
}

# install or update packages using Composer
install_composer_packages() {
    docker exec -it -u www-data:www-data -w /var/www/magento magento composer install
}

# install Magento
install_magento() {
    if [ ! -f ./magento/app/etc/env.php ]; then
        echo "Magento is not installed. Proceeding with fresh installation..."
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:install \
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
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:di:compile # DI configurations are optimized and the necessary code is pre-generated for better performance and reliability
        
    else
        echo "Magento is already installed. Skipping installation."
    fi
}

# configure Redis
configure_redis() {
    if grep -q "'session'" ./magento/app/etc/env.php && grep -q "'redis'" ./magento/app/etc/env.php; then
        echo "Redis is already configured. Skipping..."
    else 
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:config:set \
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
        echo "Redis configured successfully."
    fi
}


change_ownership() {
    current_owner=$(docker exec -it magento stat -c '%U:%G' /var/www/magento | tr -d '[:space:]')

    if [ "$current_owner" != "www-data:www-data" ]; then
        echo "Changing ownership to www-data:www-data..."
        docker exec -it magento chown -R www-data:www-data /var/www/magento
    else
        echo "Ownership is already www-data:www-data. No changes made."
    fi
}

# Function to configure Varnish
configure_varnish() {
    local varnish_status
    varnish_status=$(docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:show system/full_page_cache/caching_application | tr -d '\r')
    if [ "$varnish_status" == "2" ]; then
        echo "Varnish is already configured. Skipping..."
    else
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/caching_application 2
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_host magento
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_port 80
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/access_list 0.0.0.0
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/grace_period 300
        echo "Varnish configured successfully."
    fi
}

# Function to get Magento Admin URI
get_admin_uri() {
    docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento info:adminuri
}

# Main script execution with conditional checks
copy_files
if [ $? -eq 0 ]; then
    deploy_containers
    if [ $? -eq 0 ]; then
        install_composer_packages
        if [ $? -eq 0 ]; then
            read -p "Do you want to install Magento freshly with mention credentials in docker-compose.yaml? (yes/no): " install_choice
            case "$install_choice" in 
                y|Y|yes|Yes|YES)
                    install_magento
                    if [ $? -eq 0 ]; then
                        configure_redis
                        if [ $? -eq 0 ]; then
                            change_ownership
                            if [ $? -eq 0 ]; then
                                configure_varnish
                                if [ $? -eq 0 ]; then
                                    get_admin_uri
                                    if [ $? -eq 0 ]; then
                                        echo "All steps executed successfully."
                                    else
                                        echo "Failed to retrieve Admin URI."
                                        exit 1
                                    fi
                                else
                                    echo "Failed to configure Varnish."
                                    exit 1
                                fi
                            else
                                echo "Failed to change ownership."
                                exit 1
                            fi
                        else
                            echo "Failed to configure Redis."
                            exit 1
                        fi
                    else
                        echo "Failed to install Magento."
                        exit 1
                    fi
                    ;;
                *)
                    echo "Skipping Magento installation."
                    configure_redis
                    if [ $? -eq 0 ]; then
                        change_ownership
                        if [ $? -eq 0 ]; then
                            configure_varnish
                            if [ $? -eq 0 ]; then
                                get_admin_uri
                                if [ $? -eq 0 ]; then
                                    echo "All steps executed successfully."
                                else
                                    echo "Failed to retrieve Admin URI."
                                    exit 1
                                fi
                            else
                                echo "Failed to configure Varnish."
                                exit 1
                            fi
                        else
                            echo "Failed to change ownership."
                            exit 1
                        fi
                    else
                        echo "Failed to configure Redis."
                        exit 1
                    fi
                    ;;
            esac
        else
            echo "Failed to install Composer packages."
            exit 1
        fi
    else
        echo "Failed to deploy containers."
        exit 1
    fi
else
    echo "Failed to copy files."
    exit 1
fi