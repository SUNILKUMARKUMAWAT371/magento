#!/bin/bash

# Function to read input with a prompt
read_input() {
    local prompt="$1"     # $1 will refer argument which is pass from the function calling
    local input_var
    while true; do
        read -p "$prompt" input_var
        if [[ -n "$input_var" ]]; then   # -n check the length of the string is non-zero (i.e., the string is not empty).
            echo "$input_var"
            return 0 # pass
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
}

# Function to validate paths
validate_path() {
    local path="$1"                 # $1 will refer argument which is pass from the function calling
    if [[ ! -e "$path" ]]; then     # ! invert the condition, -e checks if the file or directory exists, 
        echo "Error: Path '$path' does not exist. Please provide a valid path."
        exit 1
    fi
}


# we create directory volume for redis mysql elasticsearch
data_persist_volume () {
    echo "volume create sucsessfully..."
    # directories=("mysql" "elasticsearch" "redis-data")

    # # Loop through the directory names
    # for dir in "${directories[@]}"; do
    # # Check if the directory exists
    # if [ -d "$dir" ]; then
    #     echo "Directory $dir already exists, skipping..."
    # else
    #     # Create the directory if it does not exist
    #     mkdir "$dir"
    #     echo "Directory $dir created."
    # fi
    # done
}

# copy virtual hosting and script(permission and fpm start) files if they don't exist
copy_files() {
    echo "copy file sucsessfully..."
    # if [ ! -f ./magento/magento2.conf ] && [ ! -f ./magento/script.sh ]; then
    #     cp -r magento2.conf magento/
    #     cp -r script.sh magento/
    #     echo "Magento virtual hosting and script.sh file copied successfully."
    # else
    #     echo "Magento virtual hosting and script.sh already exist."
    # fi  
}

# deploy Docker containers
deploy_containers() {
    echo "deploying the container......"
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
    echo "composer installed"
    # docker exec -it -u www-data:www-data -w /var/www/magento magento composer install
}

# install Magento
install_magento() {
    echo "magento installed successfully"
    # if [ ! -f ./magento/app/etc/env.php ]; then
    #     echo "Magento is not installed. Proceeding with fresh installation..."
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:install \
    #         --base-url=http://localhost \
    #         --db-host=mysql \
    #         --db-name=magento \
    #         --db-user=magento \
    #         --db-password="magento@123" \
    #         --admin-firstname=Admin \
    #         --admin-lastname=User \
    #         --admin-email=admin@magento-dev.com \
    #         --admin-user=admin \
    #         --admin-password=magento@123 \
    #         --language=en_US \
    #         --currency=USD \
    #         --timezone=America/Chicago \
    #         --use-rewrites=1 \
    #         --search-engine=elasticsearch7 \
    #         --elasticsearch-host=elasticsearch \
    #         --elasticsearch-port=9200
    #     echo "Magento installation completed."
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:di:compile # DI configurations are optimized and the necessary code is pre-generated for better performance and reliability
        
    # else
    #     echo "Magento is already installed. Skipping installation."
    # fi
}

# configure Redis
configure_redis() {
    echo "redis configured successfully"
    # if grep -q "'session'" ./magento/app/etc/env.php && grep -q "'redis'" ./magento/app/etc/env.php; then
    #     echo "Redis is already configured. Skipping..."
    # else 
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:config:set \
    #         --cache-backend=redis \
    #         --cache-backend-redis-server=redis \
    #         --cache-backend-redis-port=6379 \
    #         --cache-backend-redis-db=0 \
    #         --cache-backend-redis-password= \
    #         --session-save=redis \
    #         --session-save-redis-host=redis \
    #         --session-save-redis-port=6379 \
    #         --session-save-redis-log-level=4 \
    #         --session-save-redis-db=1 \
    #         --session-save-redis-password= \
    #         --page-cache=redis \
    #         --page-cache-redis-server=redis \
    #         --page-cache-redis-port=6379 \
    #         --page-cache-redis-db=2 \
    #         --page-cache-redis-password= \
    #         --no-interaction
    #     echo "Redis configured successfully."
    # fi
}


change_ownership() {
    echo "ownership change successfully"
    # current_owner=$(docker exec -it magento stat -c '%U:%G' /var/www/magento | tr -d '[:space:]')

    # if [ "$current_owner" != "www-data:www-data" ]; then
    #     echo "Changing ownership to www-data:www-data..."
    #     docker exec -it magento chown -R www-data:www-data /var/www/magento
    # else
    #     echo "Ownership is already www-data:www-data. No changes made."
    # fi
}

# Function to configure Varnish
configure_varnish() {
    echo "varnish successfully"
    # local varnish_status
    # varnish_status=$(docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:show system/full_page_cache/caching_application | tr -d '\r')
    # if [ "$varnish_status" == "2" ]; then
    #     echo "Varnish is already configured. Skipping..."
    # else
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/caching_application 2
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_host magento
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/backend_port 80
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/access_list 0.0.0.0
    #     docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento config:set system/full_page_cache/varnish/grace_period 300
    #     echo "Varnish configured successfully."
    # fi
}

# Function to get Magento Admin URI
get_admin_uri() {
    echo "admin url successfully"
#    docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento info:adminuri
}


mysql_db_import() {

    # Import the dump file into MySQL
    docker exec -i mysql mysql -uroot -padmin magento < $db_dump_path

    # Check the exit status of mysql command
    if [ $? -eq 0 ]; then
        echo "MySQL import successful"
        return 0
    else
        echo "MySQL import failed"
        return 1
    fi
}

code_volume() {
    $code_path





}
         


echo "Do you want to proceed with a fresh Magento installation or use an existing setup?"
echo "1) Fresh Magento installation"
echo "2) Existing setup"

# Read user's choice and '-p' option makes it read as a prompt
read -p "Enter your choice (1 or 2): " choice

if [[ "$choice" -eq 1 ]]; then

    #read -p "Which Magento version do you want to install? Enter version (e.g., 2.4.3, 2.4.6, 2.4.7): " version
    #magento_url="(wget -qO- "https://github.com/magento/magento2/archive/refs/tags/$version.tar.gz" | tar xz --strip-components=1 -C /var/www/magento \)"
    
    echo "Proceeding with fresh Magento installation..."


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

    echo "Installing Magento..."
    # (Put your Magento installation commands here)

elif [[ "$choice" -eq 2 ]]; then
    echo "You chose to use an existing setup."

    # Read code location path and # function call with string is a argument which is pass in function
    code_path=$(read_input "Please provide the existing magento code location path: ") 
    validate_path "$code_path"

    # Read database dump path
    db_dump_path=$(read_input "Please provide the database dump path: ")
    validate_path "$db_dump_path"

    echo "Code location path: $code_path"
    echo "Database dump path: $db_dump_path"

    docker-compose config

    #mysql_db_import
    # if [ $? -eq 0 ]; then
    #     code_volume
    # else
    #     echo ""
    #     return 1
    # fi




    # Add your existing setup script here
    # For example, you might configure Magento with the existing code and database
    # This is just a placeholder

    echo "Setting up Magento with the provided code and database..."
    # (Put your Magento setup commands here)





else
    echo "Invalid choice. Please run the script again and choose 1 or 2."
    exit 1
fi

echo "Magento setup process completed."












































































