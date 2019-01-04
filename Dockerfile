FROM debian:jessie

# update the package sources, clamd
RUN apt-get update -y  && \
    apt-get install -y \
    clamdscan \
    libclamav-dev \
    curl wget git htop supervisor vim openssh-server software-properties-common netcat

COPY ./docker-utils/php7.1/linode.list /etc/apt/sources.list.d/

# Install all the PHP dependencies
RUN apt-get install --no-install-recommends -y build-essential apt-transport-https lsb-release ca-certificates -y
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Install all the PHP dependencies
RUN apt-get update -y && \
    apt-get install -y \
    mysql-client \
    php7.1-dev \
    php7.1 \
    php7.1-cli \
    php7.1-fpm \
    php7.1-mcrypt \
    php7.1-common \
    php7.1-gd \
    php7.1-curl \
    php7.1-memcached \
    php7.1-xdebug \
    php7.1-mysql \
    php-pear \
    php7.1-mbstring \
    php7.1-apcu \
    php7.1-ctype \
    php7.1-dom \
    php7.1-iconv \
    php7.1-imagick \
    php7.1-json \
    php7.1-intl \
    php7.1-opcache \
    php7.1-pdo \
    php7.1-mysqli \
    php7.1-xml  \
    php7.1-tokenizer \
    php7.1-zip \
    php7.1-simplexml \
    php7.1-bcmath \
    php7.1-redis \
    mysql-client \
    apache2 \
    libapache2-mod-fastcgi \
    libapache2-mod-php7.1 \
    rsyslog --force-yes

# Install NodeJS and npm
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

# Enable Apache Modules
RUN a2enmod rewrite headers fastcgi actions

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install Gulp
RUN npm install -g gulp
RUN npm link gulp

# Install Drush
RUN php -r "readfile('http://files.drush.org/drush.phar');" > drush \
    && chmod +x drush \
    && mv drush /usr/bin/

# Insall MailHog and MHSendmail (replacement for sendmail)
RUN wget -O mailhog https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64 \
    && chmod +x mailhog \
    && mv mailhog /usr/bin/

RUN wget -O mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail \
    && mv mhsendmail /usr/bin/

# Install Codeception globally
RUN curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept
RUN chmod a+x /usr/local/bin/codecept

# package install is finished, clean up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./docker-utils/php7.1/php.ini /etc/php7.1/fpm/php.ini
COPY ./docker-utils/php7.1/20-xdebug.ini /etc/php7.1/fpm/conf.d/20-xdebug.ini
COPY ./docker-utils/php7.1cli/php.ini /etc/php7.1/cli/php.ini
COPY ./docker-utils/apache2/ports.conf /etc/apache2/
COPY ./docker-utils/apache2/mods-enabled/*.conf /etc/apache2/mods-enabled/
COPY ./docker-utils/supervisord/*.conf /etc/supervisor/conf.d/
COPY ./docker-utils/ /docker-utils/
COPY ./docker-utils/home /var/www/home

RUN a2dissite 000-default

# Setup some infra for SSHD
RUN mkdir -p /var/run/sshd
RUN mkdir -p ~/.ssh/
# Copy our Drush Aliases to the container root user
#ADD ./docker-utils/drush/* /root/.drush/

# clean up tmp files (we don't need them for the image)
RUN rm -rf /tmp/* /var/tmp/*


# Start our Services
CMD ["/docker-utils/scripts/start-services.sh"]

# Contains the Mac hack to get the permissions to work for development.
# Set user 1000 and group staff to www-data, enables write permission.
# https://github.com/boot2docker/boot2docker/issues/581#issuecomment-114804894
# TODO: Evaluate whether this is working/helping
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data
