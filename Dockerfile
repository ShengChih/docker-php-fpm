FROM ubuntu:latest
MAINTAINER ms0529756@gmail.com

ENV PHP_VER 7.3.4
ENV PATH $PATH:/usr/local/php7/bin:/usr/local/php7/sbin

EXPOSE 9000

RUN apt-get update -y \
        && apt list --upgradable \
        && apt-get install -y wget vim git build-essential autoconf \
            re2c bison libxml2 libxml2-dev \
            locate net-tools \
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
        && make -j2 && make install \
        && mkdir /usr/local/php7/etc/conf.d \
        && cp php.ini-production /usr/local/php7/lib/php.ini \
        && cp sapi/fpm/www.conf /usr/local/php7/etc/php-fpm.d/www.conf \
        && cp sapi/fpm/php-fpm.conf /usr/local/php7/etc/php-fpm.conf \
        && echo "zend_extension=opcache.so" >> /usr/local/php7/etc/conf.d/modules.ini

COPY www.conf /usr/local/php7/etc/php-fpm.d/www.conf
COPY .gitconfig /root/.gitconfig
CMD ['/usr/local/php7/sbin/php-fpm']