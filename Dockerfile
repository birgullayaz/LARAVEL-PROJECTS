FROM php:8-alpine
WORKDIR /var/www/html
COPY . ./saide_backoffice_web_app
RUN apk update && apk add  nodejs && apk add yarn && apk add php-curl && apk add curl
# Install dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    mysql-dev \
    sqlite-dev
# Install production dependencies
RUN apk add --no-cache \
    php-mbstring \
    php-xml \
    curl \
    freetype-dev \
    gcc \
    icu-dev \
    icu-libs \
    imagemagick \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    zlib-dev \
    php-gd \
    php-intl \
    php-xsl
RUN set -ex \
  && apk --no-cache add postgresql-libs postgresql-dev \
  && docker-php-ext-install pgsql pdo_pgsql \
  && apk del postgresql-dev
# Install extensions
RUN docker-php-ext-install \
    bcmath \
    exif \
#    iconv \
    intl \
#    pdo \
    pcntl \
    xml \
    zip
# Configure GD
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && rm -rf /tmp/*
RUN apk add composer
RUN cd saide_backoffice_web_app && composer install --ignore-platform-reqs && composer dump-autoload && php artisan cache:clear && php artisan config:clear
EXPOSE 8001
CMD [ "php", "saide_backoffice_web_app/artisan", "serve","--host","0.0.0.0","--port=8001"]
