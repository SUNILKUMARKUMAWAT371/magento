**Magento Setup and Configuration Package**

This package is designed to set up and run a Magento 2.4.7 application efficiently. It includes configurations for database and Redis connections, ensuring smooth integration and performance optimization. Follow these instructions to get the Magento 2.4.7 application set up and running on your local machine.


## Prerequisites
**Ports**: Ensure ports 80 and 8080 are available.
**Docker** and **Docker-Compose**
**PHP** (v8.3)
**Composer**
**MySQL** (v8.0)
**Redis** (v7.2)
**Web Server** (Nginx)
**Elasticsearch** (v8.11.0)
**Varnish** (v7.4)
**phpMyAdmin**


**Package Overview**
This package will run as a containerized service, so make sure Docker and Docker Compose are installed on your system.

**Docker Configuration**
We have created a stateless Dockerfile that includes all necessary dependencies such as PHP, PHP-FPM, Composer, Nginx, etc. This Dockerfile will be included in a docker-compose.yml file to build a Docker image with all required dependencies for our application.

**Data Storage**
We use the current path where the script is run for storing the data of the Magento application code, MySQL, Elasticsearch, etc.

**Services Deployment**
We will deploy the MySQL database, Redis, Elasticsearch, Varnish, and phpMyAdmin using the docker-compose.yml file.

**Configuration Commands**
All configuration commands for the application are present in the main.sh file. You can provide the credentials for respective services like DB details and Magento admin credentials interactively when running the script.

**Virtual Hosting and Configuration Files**
When the script or package runs, it copies all necessary virtual hosting or configuration files for Nginx and Varnish at runtime.


## Services

**Varnish**
We use Varnish caching server to boost website performance by caching HTTP responses, operating on port 80. Ensure that port 80 is available when you execute the code.

**Redis**
Redis is used for caching to improve page load times and for session storage to manage user sessions efficiently. This enhances overall site performance and scalability.

**Elasticsearch**
Elasticsearch is used to enhance search capabilities, providing faster and more accurate search results, and improving overall user experience by handling large catalogs efficiently. It supports advanced features like faceted search, autocomplete suggestions, and synonyms, making product discovery easier for customers.

**phpMyAdmin**
We deploy phpMyAdmin to interact with the MySQL database. This service will be accessible on port 8080.



## Steps to Execute the Script

Run the following command to execute the script:

    bash ./main.sh

After executing the script, it will ask various questions in interactive mode such as port availability, Docker installation, Magento installation, credentials, etc. Finally, it provides the admin URL at the bottom which can be accessed at http://localhost/<admin-id>. It also provides the URL for phpMyAdmin at http://localhost:8080/.


**Application URLs**
Magento URL: http://localhost/
Magento Admin URL: http://localhost/<admin-id>
phpMyAdmin URL: http://localhost:8080