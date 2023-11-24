# Use a base image with PHP and Apache
FROM php:7.4-apache

# Set environment variables for admin email and password
ENV PUFFERPANEL_ADMIN_EMAIL=admin@admin.com
ENV PUFFERPANEL_ADMIN_PASSWORD=admin

# Install dependencies
RUN apt-get update && \
    apt-get install -y git curl unzip libzip-dev libpng-dev libicu-dev && \
    docker-php-ext-install pdo_mysql zip gd intl

# Clone PufferPanel repository
RUN git clone --branch develop --depth 1 https://github.com/PufferPanel/PufferPanel.git /var/www/html

# Set up PufferPanel
WORKDIR /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install --no-dev --optimize-autoloader && \
    chmod -R 755 storage bootstrap && \
    php artisan pufferpanel:install --admin.email=$PUFFERPANEL_ADMIN_EMAIL --admin.password=$PUFFERPANEL_ADMIN_PASSWORD

# Expose port 8080
EXPOSE 8080

# Create necessary directories and volumes
RUN mkdir -p /var/lib/pufferpanel
VOLUME /etc/pufferpanel
VOLUME /var/lib/pufferpanel
VOLUME /var/run/docker.sock

# Start Apache
CMD ["apache2-foreground"]
