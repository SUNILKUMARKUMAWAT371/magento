FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common curl tzdata && \
    add-apt-repository ppa:ondrej/php  && apt-get update -y
    
RUN apt-get update && \
    apt-get install -y \
    nginx \
    curl \
    wget \
    net-tools \
    git \
    unzip \
    vim \
    php8.3 \
    php8.3-fpm \
    php8.3-cli \
    php8.3-mysql \
    php8.3-xml \
    php8.3-curl \
    php8.3-zip \
    php8.3-intl \
    php8.3-mbstring \
    php8.3-bcmath \
    php8.3-soap \
    php8.3-gd \
    php8.3-xsl \
    php8.3-iconv \
    php8.3-opcache \
    php8.3-gettext \
    php8.3-dev \
    libmcrypt-dev 

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
 
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 