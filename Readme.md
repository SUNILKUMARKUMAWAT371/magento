This package is designed to set up and run a Magento application efficiently. It includes configurations for database and Redis connections, ensuring smooth integration and performance optimization. Whether you are setting up a fresh Magento instance or running an existing project.

* Follow these instructions to get the Magento2.4.7 application up and running on your local machine.

## Prerequisites
- **PHP** (v8.3)
- **Composer**
- **MySQL** (v8.0)
- **Redis** (v7.2)
- **Web server** (Nginx)
- **Elasticserch** (v8.11.0)
- **Varnish** (v7.4)

    We have create a stateless Dockerfile that includes all necessary dependencies such as PHP, PHP-FPM, Composer, Nginx, etc. This Dockerfile will be included in a docker-compose.yml to build a Docker image with all required dependencies our application.

## Fresh Magento setup
     we have configured database credentials and Redis in **docker-compose.yaml** and **bash.sh** files. You can change the credentials according to your convience.

## Existing Magento Setupped 
    Place the code into the Magento folder. We use a **docker-compose.yaml** file that attaches the Magento volume and automatically mounts the entire code into the container. Additionally, update any credentials or configurations in the 'bash.sh' file. Regarding mysql database migration will happen for data of our appication.

## Varnish
Here we use **Varnish** caching server to boost website performance by caching HTTP responses, operating on port 80. Ensure that when you execute the code, port 80 should be available.

## Redis
Redis is used for caching to improve page load times and for session storage to manage user sessions efficiently. This enhances overall site performance and scalability.

## Elasticsearch
Elasticsearch is used to enhance search capabilities, providing faster and more accurate search results, and improving overall user experience by handling large catalogs efficiently. It supports advanced features like faceted search, autocomplete suggestions, and synonyms, making product discovery easier for customers.

## Steps to execute the commands 

    bash ./bash.sh

    After excute the script they gave admin url on bottom which is use after http://localhost/

## URL of application
    
    User - http://localhost


## Notes

    We should changes in these files and directory i.e magento, docker-compose.yaml, bash.sh
    Here is a folder or directory named 'magento' where we need to place the application code.