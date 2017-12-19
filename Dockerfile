FROM moodlehq/moodle-php-apache:7.1

ENV DEBIAN_FRONTEND noninteractive

RUN a2enmod rewrite

RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN	apt-get install -y libpq-dev
RUN	docker-php-ext-install pdo_pgsql

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install --yes nodejs
RUN apt-get install --yes build-essential

RUN apt-get update && apt-get install -y curl apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn
