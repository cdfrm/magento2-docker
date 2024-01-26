FROM php:8.1-fpm

USER root

WORKDIR /var/www

ENV TIDEWAYS_APIKEY=i7336kfWfK8vHwlA
ENV TIDEWAYS_SERVICE=app
ENV TIDEWAYS_SAMPLERATE=25
ENV TIDEWAYS_CONNECTION=tcp://tideways-daemon:9135

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libicu-dev \
    libsodium-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libmcrypt-dev \
    libssl-dev \
    git vim unzip cron sudo openssh-server openssl \
    --no-install-recommends

RUN docker-php-ext-configure gd --with-jpeg=/usr/include \
    --with-freetype=/usr/include/freetype2 \
    && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl

RUN docker-php-ext-install -j$(nproc) \
    opcache \
    bcmath \
    mysqli \
    pdo_mysql \
    soap \
    xsl \
    zip \
    sockets \
    sodium

# Install Composer
RUN curl https://getcomposer.org/composer-2.phar -o composer \
    && mv composer /usr/local/bin/composer && chmod 755 /usr/local/bin/composer

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs
    
RUN curl -sS https://get.symfony.com/cli/installer | bash - \

    &&  mv /root/.symfony5/bin/symfony /usr/local/bin/symfony && chmod 755 /usr/local/bin/symfony

RUN git config --global user.email "daipham31@outlook.com" \ 
    && git config --global user.name "Dai Pham"

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -r /var/lib/apt/lists/*
    
RUN apt-get update -yq && \
    apt-get install -yq --no-install-recommends gpg wget ca-certificates && \
    echo 'deb [signed-by=/usr/share/keyrings/tideways.gpg] https://packages.tideways.com/apt-packages-main any-version main' | tee /etc/apt/sources.list.d/tideways.list && \
    wget -qO - 'https://packages.tideways.com/key.gpg' | gpg --dearmor > /usr/share/keyrings/tideways.gpg && \
    apt-get update -yq && \
    apt-get install -yq tideways-php && \
    apt-get clean -yq

CMD ["php-fpm"]
