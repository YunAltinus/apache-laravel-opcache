# Development Dockerfile

FROM php:8.2-apache

# Apache ve PHP modüllerini kur
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    redis-server \
    supervisor \
    && docker-php-ext-install zip pdo pdo_mysql opcache pcntl posix

# Xdebug kur
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Redis PHP uzantısını kur
RUN pecl install redis && docker-php-ext-enable redis

# Composer kur
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apache yapılandırma dosyası
COPY vhost.conf /etc/apache2/sites-available/000-default.conf

# Apache modlarını etkinleştir
RUN a2enmod rewrite

# Geliştirme spesifik PHP ayarları
COPY php.ini /usr/local/etc/php/php.ini

# Opcache ayarları
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Supervisor yapılandırma dosyası
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /var/www/html

# Uygulama dosyalarını kopyala
COPY ./www .

# Kullanıcı tanımlaması (opsiyonel)
# RUN useradd -ms /bin/bash developer
# USER developer

# Container başlatıldığında çalıştırılacak komut
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
