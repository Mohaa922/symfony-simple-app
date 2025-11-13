FROM php:8.3-apache

# 1) Paquets système
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        libicu-dev \
    ; \
    docker-php-ext-install intl; \
    rm -rf /var/lib/apt/lists/*

# 2) Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 3) Code Symfony
WORKDIR /var/www/html
COPY . .

# 4) Git safe dir (pour composer)
RUN git config --global --add safe.directory /var/www/html || true

# 5) Dépendances PHP (en dev)
RUN composer install --no-interaction --prefer-dist --no-progress

# 6) Droits sur var/ (cache + logs)
RUN mkdir -p var/cache var/log \
 && chown -R www-data:www-data var \
 && chmod -R 775 var

# 7) Adapter le DocumentRoot d’Apache
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/000-default.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
