#!/bin/bash

# Define the URL and target directory
URL="https://github.com/magento/magento2/archive/refs/tags/2.4.7.tar.gz"
TARGET_DIR="/var/www/magento"
TEMP_FILE="/tmp/magento2-2.4.7.tar.gz"

# Download the file
echo "Downloading Magento 2.4.7..."
wget -q -O $TEMP_FILE $URL

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Download complete. Extracting the files..."
    # Extract the files
    tar xz --strip-components=1 -C $TARGET_DIR -f $TEMP_FILE

    # Check if the extraction was successful
    if [ $? -eq 0 ]; then
        echo "Extraction complete."
    else
        echo "Error: Extraction failed."
    fi

    # Remove the temporary file
    rm $TEMP_FILE
else
    echo "Error: Download failed."
fi


# Change ownership and permissions
chown -R www-data:www-data /var/www/magento \

chmod -R 755 /var/www/magento \

# Copy the Magento Nginx configuration(virtualhosting)
cp -r /var/www/magento/magento2.conf /etc/nginx/sites-enabled/ \

# Remove the default Nginx configuration
rm -rf /etc/nginx/sites-enabled/default \

# Start the PHP-FPM service
service php8.3-fpm start