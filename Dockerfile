FROM moodlehq/moodle-php-apache:7.1

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo_pgsql
