FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

ARG ENV=production

RUN apt-get update \ 
	&& apt-get install -y software-properties-common \
	&& LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php \
	&& apt-get update -y \
    && apt-get -y install \
        apt-utils \
        apache2 \
        libapache2-mod-php7.1 \
        php7.1 \
        php7.1-cli \
        php-xdebug \
        php7.1-mbstring \
        php7.1-pgsql \
        php-apcu \
        php-apcu-bc \
        php-imagick \
        php-memcached \
        php-pear \
        php7.1-dom \
        php7.1-xml \
        php7.1-dev \
        php7.1-phpdbg \
        php7.1-gd \
        php7.1-json \
        php7.1-curl \
        php7.1-intl \
        php7.1-zip \
        php7.1-bcmath \
        libpng-dev \
        imagemagick \
        apache2 \
        git-core \
        curl \
        zip \
        unzip \
        libpq-dev \
        cron \
        supervisor \
        openssh-client \
	&& a2enmod headers \
	&& a2enmod rewrite

# supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# cron job
COPY crontab /etc/cron.d/cron-moodle
RUN chmod 0644 /etc/cron.d/cron-moodle
RUN crontab /etc/cron.d/cron-moodle

# install node and yarn
RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs build-essential
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Install composer for PHP dependencies
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# apache related
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR
RUN chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" /var/www/html
RUN mkdir -p /var/www/moodledata
RUN chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" /var/www/moodledata
VOLUME [ "/var/www/moodledata" ]

COPY ./app /var/www/html
WORKDIR /var/www/html

EXPOSE 80

RUN composer install --verbose --prefer-dist --no-progress --no-interaction --no-suggest --optimize-autoloader
RUN yarn install --pure-lockfile --ignore-optional --silent
RUN yarn run $ENV

COPY ./entrypoint.sh /usr/src/entrypoint.sh
ENTRYPOINT ["sh", "/usr/src/entrypoint.sh"]
