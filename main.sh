# Function to check if a port is open
check_port() {
    local port=$1
    if nc -zv 127.0.0.1 $port 2>&1 | grep -q 'succeeded'; then
        echo "Port $port is open or already in use. "
        return 1
    else
        echo "Port $port is available."
        return 0
    fi
}

# Check if Docker is installed
check_docker_installed() {
    if command -v docker &> /dev/null
    then
        echo "Docker is installed."
        return 0
    else
        echo "Docker is not installed."
        return 1
    fi
}

# Check if Docker-Compose is installed
check_docker_compose_installed() {
    if command -v docker-compose &> /dev/null
    then
        echo "Docker Compose is installed."
        return 0
    else
        echo "Docker Compose is not installed."
        return 1
    fi
}



# we create directory volume for redis mysql elasticsearch
data_persist_volume () {
    directories=("mysql" "elasticsearch" "redis-data" "varnish" "magento") 

    # Loop through the directory names
    for dir in "${directories[@]}"; do
        # Check if the directory exists
        if [ -d "$dir" ]; then
            echo "Directory $dir already exists, skipping..."
        else
            # Create the directory if it does not exist
            mkdir "$dir"
            echo "Directory $dir created."
        fi
    done
}

# copy virtual hosting and script(permission and fpm start) files if they don't exist
copy_files() {


    if [ ! -f ./magento/magento2.conf ]; then

        cp -r magento2.conf magento/
        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Magento virtual hosting file copied successfully......"
        else
            echo "Magento virtual hosting file copied failed......"
            exit 1
        fi

    else
        echo "Magento virtual hosting files already exist."
    fi  

        
    if [ ! -f ./magento/script.sh ]; then

        cp -r script.sh magento/
        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "script file copied successfully......"
        else
            echo "script file copied failed......"
            exit 1
        fi

    else
        echo "script file already exist."
    fi  


    if [ ! -f ./varnish/varnish.vcl ]; then

        cp -r varnish.vcl varnish/
        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "varnish configuration file copied successfully......"
        else
            echo "varnish configuration file copied failed......"
            exit 1
        fi
    
     else
         echo "varnish configuration file already exist."
     fi  
}

# install or update packages using Composer
install_composer_packages() {

    docker exec -it -u www-data:www-data -w /var/www/magento magento composer install

    if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Composer installed successfully......"
        else
            echo "Composer installed failed......"
            exit 1
        fi

}

# Install Magento
install_magento() {
    
        echo "Proceeding with fresh installation..."

        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:install \
            --base-url=http://localhost \
            --db-host=mysql \
            --db-name=$MYSQL_DATABASE \
            --db-user=$MYSQL_USER \
            --db-password=$MYSQL_PASSWORD \
            --admin-firstname=$ADMIN_FIRSTNAME \
            --admin-lastname=$ADMIN_LASTNAME \
            --admin-email=$ADMIN_EMAIL \
            --admin-user=$ADMIN_USER \
            --admin-password=$ADMIN_PASSWORD \
            --language=en_US \
            --currency=USD \
            --timezone=America/Chicago \
            --use-rewrites=1 \
            --search-engine=elasticsearch7 \
            --elasticsearch-host=elasticsearch \
            --elasticsearch-port=9200

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Magento configuration or installed with db connection and admin login successfully......"
        else
            echo "Magento configuration or installed failed......"
            exit 1
        fi

        # DI configurations are optimized and the necessary code is pre-generated for better performance and reliability
        docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento setup:di:compile 

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Magento setup di compilation successfully......"
        else
            echo "Magento setup di compilation failed......"
            exit 1
        fi

}


# configure Redis
configure_redis() { 
    
    echo "Proceeding with Redis Configuration with Magento..."

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

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Redis configured with magento successfully......"
        else
            echo "Redis configured with magento failed......"
            exit 1
        fi
}

change_ownership() {

    current_owner=$(docker exec -it magento stat -c '%U:%G' /var/www/magento | tr -d '[:space:]')

    if [ "$current_owner" != "www-data:www-data" ]; then

        docker exec -it magento chown -R www-data:www-data /var/www/magento

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Changing ownership to www-data:www-data successfully......"
        else
            echo "Changing ownership to www-data:www-data failed......"
            exit 1
        fi


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

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Varnish is configured successfully......"
        else
            echo echo "Varnish is configured failed......"
            exit 1
        fi

    fi
}

# Function to get Magento Admin URI
get_admin_uri() {
    echo "admin url successfully"
    docker exec -it -u www-data:www-data -w /var/www/magento magento bin/magento info:adminuri
}


#############################################  Port 80 and 8080 available

read -p "Ensure the port 80 and 8080 must be available to run the complete package of application (y/n): " verify_port

if [ "$verify_port" == "y" ]; then

    # Check ports 80 and 8080
    check_port 80
    port_80_status=$?

    check_port 8080
    port_8080_status=$?

    if [ $port_80_status -eq 0 ] && [ $port_8080_status -eq 0 ]; then
        echo "Both ports are available. Proceeding to the next step."
    else
        echo "Both ports 80 and 8080 must be available to run this application."
    fi

else 
    echo "Port 80 and 8080 must be available to run this application."
fi


####################################################  Docker and docker compose installed
# Check if Docker is installed
if check_docker_installed
then
    check_docker_installed_status=$?

    if check_docker_compose_installed
    then
        check_docker_compose_installed_status=$?
        # Check if the user is in the Docker group
        if groups $USER | grep &>/dev/null "\bdocker\b"
        then
            echo "User is already in the Docker group."
        else
            echo "Please add User in the Docker group....."
        fi
        check_user_dockergroup_status=$?

    else
        echo "Please first install Docker Compose"
    fi

    if [ $check_docker_installed_status -eq 0 ] && [ $check_docker_compose_installed_status -eq 0 ] && [ $check_user_dockergroup_status -eq 0 ]  ; then
        echo "docker, docker-compose and user configured with docker are available. Proceeding to the next step."
    else
        echo "Both docker and docker-compose must be available to run this application."
    fi


else
    echo "please first install Docker"
fi

# Further steps can be added here
echo "Proceeding with the next steps..."



##############################################################  Magento install freshly

echo "Do you want to proceed with a fresh Magento installation or use an existing setup?"
echo "1) Fresh Magento installation"
echo "2) Existing setup"

# Read user's choice and '-p' option makes it read as a prompt
read -p "Enter your choice (1 or 2): " choice

if [[ "$choice" -eq 1 ]]; then

    read -p "Current path for installation MAGENTO, MySql data, Elasticsearch data (yes/no) : " installation_path
    
    if [[ "$installation_path" == "yes" || "$installation_path" == "y" ]]; then
    
        current_path=$(pwd)
        echo "current path for magento is: $current_path"
        
        #creating volume for data persistent
        data_persist_volume

        # Prompt the user for MySQL configuration
        read -sp "Enter MySQL ROOT Password: " MYSQL_ROOT_PASSWORD
        echo
        read -p "Enter MySQL Database Name: " MYSQL_DATABASE
        read -p "Enter MySQL Username: " MYSQL_USER
        read -sp "Enter MySQL Password: " MYSQL_PASSWORD
        echo

        export MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
        export MYSQL_DATABASE=$MYSQL_DATABASE
        export MYSQL_USER=$MYSQL_USER
        export MYSQL_PASSWORD=$MYSQL_PASSWORD

        # copy virtual hosting and script(permission and fpm start) files if they don't exist
        copy_files

        # containers up
        docker compose -f ./docker-compose.yaml up -d

        if [ $? -eq 0 ]; then  # $? retrieves the exit status of the last executed command.
            echo "Containers are deploying successfully......"
        else
            echo "Containers are deploying failed......"
            exit 1
        fi


        sleep 10

        # install or update packages using Composer
        install_composer_packages
        

        echo "Enter the MAGENTO ADMIN configuration details"

        # Prompt the MAGENTO admin's configuration
        read -p "Enter the magento admin-firstname: " ADMIN_FIRSTNAME
        read -p "Enter the magento admin-lastname: " ADMIN_LASTNAME
        read -p "Enter the magento admin-email: " ADMIN_EMAIL
        read -p "Enter the magento admin-user: " ADMIN_USER 
        read -sp "Enter the magento admin-password: " ADMIN_PASSWORD
        echo

        export ADMIN_FIRSTNAME=$ADMIN_FIRSTNAME
        export ADMIN_LASTNAME=$ADMIN_LASTNAME
        export ADMIN_EMAIL=$ADMIN_EMAIL
        export ADMIN_USER=$ADMIN_USER
        export ADMIN_PASSWORD=$ADMIN_PASSWORD


        # Install Magento
        install_magento

        # configure Redis
        configure_redis


        # Change ownership permission
        change_ownership


        # Configure Varnish
        configure_varnish

        # get Admin Url
        get_admin_uri



    else
        echo "provide the path"

    fi


    #read -p "Which Magento version do you want to install? Enter version (e.g., 2.4.3, 2.4.6, 2.4.7): " version
    #magento_url="(wget -qO- "https://github.com/magento/magento2/archive/refs/tags/$version.tar.gz" | tar xz --strip-components=1 -C /var/www/magento \)"
    
    echo "Proceeding with fresh Magento installation..."


else
    echo "Invalid choice. Please run the script again and choose 1 or 2."
    exit 1
fi