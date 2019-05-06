FROM ubuntu:latest
MAINTAINER ms0529756@gmail.com

ENV PHP_VER 7.3.4
ENV PATH $PATH:/usr/local/php7/bin:/usr/local/php7/sbin

EXPOSE 9000

RUN apt-get update -y \
        && ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
        && apt list --upgradable \
        && apt-get install -y wget vim git build-essential autoconf \
            re2c bison libxml2 libxml2-dev \
            locate net-tools \
            libpcre3-dev \
            libbz2-dev \
            libzip4 libzip-dev \
            libreadline7 libreadline-dev \
            libedit-dev libedit2 \
            libxml2 libxml2-dev \
            libxslt1-dev libxslt1.1 \
            libssl-dev openssl \
            libcurl4 libcurl4-openssl-dev \
            gettext \
            libicu-dev \
            libmcrypt-dev libmcrypt4 \
            libmhash-dev libmhash2 \
            libgd-dev libgd3 \
            libfreetype6 libfreetype6-dev \
            libpng-dev libpng16-16 \
            libjpeg-dev libjpeg8-dev libjpeg8 \
            libxpm4 libltdl7 libltdl-dev \
            mysql-client libmysqlclient-dev libmysqld-dev \
            postgresql postgresql-client postgresql-contrib \
        && cd \
        && git clone https://github.com/php/php-src.git \
        && cd php-src/ \
        && git checkout php-$PHP_VER \
        && ./buildconf --force \
        && mkdir /usr/local/php7/ \
        && ./configure \
            --prefix=/usr/local/php7/ \
            --with-config-file-path=/usr/local/php7/etc \
            --with-config-file-scan-dir=/usr/local/php7/etc/conf.d \
            --enable-maintainer-zts \
            --enable-cli \
            --enable-fpm \
            --enable-opcache \
            --enable-session \
            --enable-short-tags \
            --enable-tokenizer \
            --with-pcre-regex \
            --with-zlib \
            --enable-dom \
            --enable-libxml \
            --enable-simplexml \
            --enable-xml \
            --enable-xmlreader \
            --enable-xmlwriter \
            --with-xsl \
            --with-libxml-dir \
            --enable-bcmath \
            --with-bz2 \
            --enable-calendar \
            --enable-ctype \
            --enable-dom \
            --enable-fileinfo \
            --enable-sysvsem --enable-sysvshm --enable-sysvmsg \
            --enable-json \
            --enable-mbregex \
            --enable-shmop \
            --enable-mbstring \
            --enable-phar \
            --with-mhash \
            --enable-pcntl \
            --with-pcre-regex \
            --with-pcre-dir \
            --enable-pdo \
            --with-pdo-mysql \
            --enable-posix \
            --with-readline \
            --enable-sockets \
            --with-curl \
            --with-openssl \
            --enable-zip \
        && make -j2 && make install \
        && mkdir /usr/local/php7/etc/conf.d \
        && cp php.ini-production /usr/local/php7/etc/php.ini \
        && cp sapi/fpm/www.conf /usr/local/php7/etc/php-fpm.d/www.conf \
        && cp sapi/fpm/php-fpm.conf /usr/local/php7/etc/php-fpm.conf \
        && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
        && php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
        && php composer-setup.php \
        && php -r "unlink('composer-setup.php');" \
        && mv composer.phar /usr/local/php7/bin \
        && ln -s /usr/local/php7/bin/composer.phar /usr/local/php7/bin/composer \
        && pecl install igbinary xdebug \
        && printf "no\n" | pecl install lzf \
        && printf "yes\nyes\n" | pecl install redis

COPY www.conf /usr/local/php7/etc/php-fpm.d/www.conf
COPY modules.ini /usr/local/php7/etc/conf.d/modules.ini
COPY .gitconfig /root/.gitconfig

STOPSIGNAL SIGQUIT

CMD ["php-fpm", "-F"]