#!/bin/bash

# Function to set Magento version and copy command to magento file
install_magento() {
    # Prompt user for Magento version
    #read -p "Which Magento version do you want to install? Enter version (e.g., 2.4.3, 2.4.6, 2.4.7): " version
    read -p "Which Magento version do you want to install? Enter version (e.g., 2.4.3, 2.4.6, 2.4.7): " version
 
        echo $version

    #magento_version=echo $version 
    sed -i 's/ls/wget -qO- "https:\/\/github.com\/magento\/magento2\/archive\/refs\/tags\/`${version}`.tar.gz" | tar xz --strip-components=1 -C \/var\/www\/magento/' ./script.sh

    # Update variable with chosen Magento version
    #magento_version="$version"

    # # Command to download Magento using the provided version
    # command="wget -qO- \"https://github.com/magento/magento2/archive/refs/tags/${magento_version}.tar.gz\" | tar xz --strip-components=1 -C /var/www/magento"

    # # Print the command to verify
    # #echo "Command to download Magento ${magento_version}:"
    # echo "$command"

    # # Copy the command to a file named 'magento'
    # echo "$command" >> magento
    # echo "Command copied to 'magento' file."
}

# Call the function to install Magento
install_magento

echo version is $version


docker compose up