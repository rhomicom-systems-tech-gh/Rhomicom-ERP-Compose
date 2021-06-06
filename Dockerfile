FROM alpine:3.8 as nginx

LABEL Maintainer="Richard Adjei-Mensah <richarda.mensah@gmail.com>" \
  Description="Lightweight container with Nginx 1.18.0 & PHP-FPM 7.4 based on Alpine Linux (forked from trafex/alpine-nginx-php7)."
#https://github.com/apache/incubator-pagespeed-ngx/releases/tag/v1.14.33.1-RC1
ENV NGINX_VERSION=1.19.4 \
  VAR_PREFIX=/var/run \
  LOG_PREFIX=/var/log/nginx \
  NGX_PAGESPEED_VER=v1.14.33.1-RC1 \
  #NGX_PAGESPEED_VER=v1.13.35.2-stable \
  MOD_PAGESPEED_VER=1.13.35.2 \
  TEMP_PREFIX=/tmp \
  CACHE_PREFIX=/var/cache \
  CONF_PREFIX=/etc/nginx \
  CERTS_PREFIX=/etc/pki/tls/ 

COPY conf/psol/ /tmp

RUN set -x  \
  && addgroup -g 82 -S nginx \
  && adduser -u 82 -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
  #&& echo -e '@community http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && echo -e '@community http://nl.alpinelinux.org/alpine/3.8/community' >> /etc/apk/repositories \
  && echo -e '@community http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
  && echo -e '@community http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk add --no-cache --update --upgrade --virtual \
  .build-deps \
  build-base \
  findutils \
  apr-dev \
  apr-util-dev \
  apache2-dev \
  libuuid \
  jemalloc-dev \
  gnupg \
  gperf \
  icu-libs icu-dev \
  gettext-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libtool \
  ca-certificates \
  automake \
  autoconf \
  git \
  libtool \
  binutils \
  gnupg \
  cmake \
  go \
  gcc \
  build-base \
  libc-dev \
  make \
  wget \
  gzip \
  libressl-dev \
  musl-dev \
  pcre-dev \
  zlib-dev \
  geoip-dev \
  git \
  linux-headers \
  libxslt-dev \
  nghttp2 \
  gd-dev \
  unzip \
  && apk add --no-cache --update --upgrade \
  curl \
  monit \
  bash \
  bind-tools \
  rsync \
  geoip \
  libressl \
  tini \
  tar \
  && cd /tmp \
  && git clone https://github.com/google/ngx_brotli --depth=1 \
  && cd ngx_brotli && git submodule update --init \
  && export NGX_BROTLI_STATIC_MODULE_ONLY=1 \
  && cd /tmp \
  && git clone https://github.com/nbs-system/naxsi.git \
  && echo 'adding /usr/local/share/GeoIP/GeoIP.dat database' \
  && wget -N https://raw.githubusercontent.com/openbridge/nginx/master/geoip/GeoLiteCity.dat.gz \
  && wget -N https://raw.githubusercontent.com/openbridge/nginx/master/geoip/GeoIP.dat.gz \
  && gzip -d GeoIP.dat.gz \
  && gzip -d GeoLiteCity.dat.gz \
  && mkdir /usr/local/share/GeoIP/ \
  && mv GeoIP.dat /usr/local/share/GeoIP/ \
  && mv GeoLiteCity.dat /usr/local/share/GeoIP/ \
  && chown -R nginx:nginx /usr/local/share/GeoIP/ \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
  && mkdir -p /usr/src \
  && tar -zxC /usr/src -f nginx.tar.gz \
  && rm nginx.tar.gz \
  && cd /tmp \
  && git clone -b "${NGX_PAGESPEED_VER}" \
  --recurse-submodules \
  --shallow-submodules \
  --depth=1 \
  -c advice.detachedHead=false \
  -j$(getconf _NPROCESSORS_ONLN) \
  https://github.com/apache/incubator-pagespeed-ngx.git \
  /tmp/ngxpagespeed \
  \
  #&& psolurl="https://github.com/wodby/nginx-alpine-psol/releases/download/${MOD_PAGESPEED_VER}/psol.tar.gz" \
  #&& wget -qO- "${psolurl}" | tar xz -C /tmp/ngxpagespeed \
  && cd /tmp \
  && tar -zxC /tmp/ngxpagespeed -f psol.tar.gz \
  && git clone https://github.com/openresty/echo-nginx-module.git \
  && wget https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip -O dev.zip \
  && wget https://github.com/openresty/set-misc-nginx-module/archive/v0.31.zip -O setmisc.zip \
  && wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.8.tar.gz \
  && wget https://github.com/openresty/redis2-nginx-module/archive/v0.14.zip -O redis.zip \
  && wget https://github.com/openresty/srcache-nginx-module/archive/v0.31.zip -O cache.zip \
  && wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.zip -O purge.zip \
  && tar -zx -f ngx_http_redis-0.3.8.tar.gz \
  && unzip dev.zip \
  && unzip setmisc.zip \
  && unzip redis.zip \
  && unzip cache.zip \
  && unzip purge.zip \
  && cd /usr/src/nginx-$NGINX_VERSION \
  && ./configure \
  --prefix=/usr/share/nginx/ \
  --sbin-path=/usr/sbin/nginx \
  --add-module=/tmp/naxsi/naxsi_src \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=${CONF_PREFIX}/nginx.conf \
  --error-log-path=${LOG_PREFIX}/error.log \
  --http-log-path=${LOG_PREFIX}/access.log \
  --pid-path=${VAR_PREFIX}/nginx.pid \
  --lock-path=${VAR_PREFIX}/nginx.lock \
  --http-client-body-temp-path=${TEMP_PREFIX}/client_temp \
  --http-proxy-temp-path=${TEMP_PREFIX}/proxy_temp \
  --http-fastcgi-temp-path=${TEMP_PREFIX}/fastcgi_temp \
  --http-uwsgi-temp-path=${TEMP_PREFIX}/uwsgi_temp \
  --http-scgi-temp-path=${TEMP_PREFIX}/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-file-aio \
  --with-http_ssl_module \
  --with-pcre-jit \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-threads \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-http_slice_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-compat \
  --with-http_v2_module \
  --with-ld-opt="-Wl,-z,relro,--start-group -lapr-1 -laprutil-1 -licudata -licuuc -lpng -lturbojpeg -ljpeg" \
  --add-module=/tmp/ngx_cache_purge-2.3 \
  --add-module=/tmp/ngx_http_redis-0.3.8 \
  --add-module=/tmp/redis2-nginx-module-0.14 \
  --add-module=/tmp/srcache-nginx-module-0.31 \
  --add-module=/tmp/echo-nginx-module \
  --add-module=/tmp/ngx_devel_kit-0.3.0 \
  --add-module=/tmp/set-misc-nginx-module-0.31 \
  --add-module=/tmp/ngx_brotli \
  --add-module=/tmp/ngxpagespeed \
  \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && mv objs/nginx objs/nginx-debug \
  && mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
  && mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
  && mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
  && ./configure \
  --prefix=/etc/nginx/ \
  --sbin-path=/usr/sbin/nginx \
  --add-module=/tmp/naxsi/naxsi_src \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=${CONF_PREFIX}/nginx.conf \
  --error-log-path=${LOG_PREFIX}/error.log \
  --http-log-path=${LOG_PREFIX}/access.log \
  --pid-path=${VAR_PREFIX}/nginx.pid \
  --lock-path=${VAR_PREFIX}/nginx.lock \
  --http-client-body-temp-path=${TEMP_PREFIX}/client_temp \
  --http-proxy-temp-path=${TEMP_PREFIX}/proxy_temp \
  --http-fastcgi-temp-path=${TEMP_PREFIX}/fastcgi_temp \
  --http-uwsgi-temp-path=${TEMP_PREFIX}/uwsgi_temp \
  --http-scgi-temp-path=${TEMP_PREFIX}/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-file-aio \
  --with-http_ssl_module \
  --with-pcre-jit \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-threads \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-http_slice_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-compat \
  --with-http_v2_module \
  --with-ld-opt="-Wl,-z,relro,--start-group -lapr-1 -laprutil-1 -licudata -licuuc -lpng -lturbojpeg -ljpeg" \
  --add-module=/tmp/ngx_cache_purge-2.3 \
  --add-module=/tmp/ngx_http_redis-0.3.8 \
  --add-module=/tmp/redis2-nginx-module-0.14 \
  --add-module=/tmp/srcache-nginx-module-0.31 \
  --add-module=/tmp/echo-nginx-module \
  --add-module=/tmp/ngx_devel_kit-0.3.0 \
  --add-module=/tmp/set-misc-nginx-module-0.31 \
  --add-module=/tmp/ngx_brotli \
  --add-module=/tmp/ngxpagespeed \
  \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && rm -rf /etc/nginx/html/ \
  && mkdir -p /etc/nginx/conf.d/ \
  && mkdir -p /usr/share/nginx/html/ \
  && install -m644 html/index.html /usr/share/nginx/html/ \
  && install -m644 html/50x.html /usr/share/nginx/html/ \
  && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
  && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
  && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
  && install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
  && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
  && strip /usr/sbin/nginx* \
  && strip /usr/lib/nginx/modules/*.so \
  && mkdir -p /usr/local/bin/ \
  && mkdir -p ${CACHE_PREFIX} \
  && mkdir -p ${CERTS_PREFIX} \
  && cd ${CERTS_PREFIX} \
  && openssl dhparam 2048 -out ${CERTS_PREFIX}/dhparam.pem.default \
  && apk add --no-cache --virtual .gettext gettext \
  && mv /usr/bin/envsubst /tmp/ \
  \
  && runDeps="$( \
  scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
  | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
  | sort -u \
  | xargs -r apk info --installed \
  | sort -u \
  )" \
  && apk add --no-cache --virtual .nginx-rundeps $runDeps \
  && apk del .build-deps \
  && apk del .gettext \
  && cd /tmp/naxsi \
  && mv naxsi_config/naxsi_core.rules /etc/nginx/naxsi_core.rules \
  && mv /tmp/envsubst /usr/local/bin/ \
  && rm -rf /tmp/* \
  && rm -rf /usr/src/* \
  && ln -sf /dev/stdout ${LOG_PREFIX}/access.log \
  && ln -sf /dev/stderr ${LOG_PREFIX}/error.log \
  && ln -sf /dev/stdout ${LOG_PREFIX}/blocked.log

##########################################
# Combine everything with minimal layers #
##########################################
FROM php:7.4.19-fpm-alpine3.13
LABEL Maintainer="Richard Adjei-Mensah <richarda.mensah@gmail.com>" \
  Description="Lightweight container with Nginx 1.19.4 & PHP-FPM 7.4 based on Alpine Linux (forked from trafex/alpine-nginx-php7)."

ENV php_conf /etc/php7/php.ini
ENV fpm_conf /etc/php7/php-fpm.d/www.conf

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
#ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN apk update 
RUN apk add --no-cache --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
  --upgrade openssl-dev ca-certificates \
  curl \
  tar \
  xz \
  zip \
  unzip \
  gzip \
  nano wget 

RUN cd /tmp \ 
  && export PATH="/usr/bin:$PATH" 

COPY --from=nginx /usr/local/bin/envsubst /usr/local/bin/envsubst
COPY --from=nginx /usr/sbin/nginx /usr/sbin/nginx
COPY --from=nginx /usr/lib/nginx/modules/ /usr/lib/nginx/modules/
COPY --from=nginx /etc/nginx /etc/nginx
COPY --from=nginx /usr/share/nginx/html/ /usr/share/nginx/html/

ENV PHPIZE_DEPS \
  autoconf \
  dpkg-dev dpkg \
  file \
  g++ \
  gcc \
  libc-dev \
  make \
  cmake \
  pkgconf \
  re2c

# persistent dependencies
RUN apk add --no-cache \
  bash \
  sed \
  ghostscript \
  git diffutils \
  python3 \
  imagemagick
#
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories
RUN apk --no-cache upgrade && \ 
  scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so /usr/local/bin/envsubst \
  | tr ',' '\n' \
  | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  | xargs apk add --no-cache --update --upgrade 
#RUN sed -i -e 's|http://dl-cdn.alpinelinux.org/alpine/v3.8/community||g' /etc/apk/repositories
#RUN sed -i -e 's|http://dl-cdn.alpinelinux.org/alpine/v3.8/main||g' /etc/apk/repositories
RUN apk upgrade --available

#--repository http://dl-cdn.alpinelinux.org/alpine/edge/community 
#'icu-libs>=67.1-r1' 'icu-dev>=67.1-r1' \
RUN set -ex; \
  \
  apk add --no-cache --update --upgrade --virtual .build-deps \
  $PHPIZE_DEPS \
  icu-libs icu-dev \
  freetype-dev \
  imagemagick-dev \
  libjpeg-turbo-dev \
  libpng-dev libxml2-dev \
  libzip-dev libmemcached cyrus-sasl-dev libmemcached-dev

RUN apk add --no-cache --update --upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  php php-fpm php-opcache php-openssl php-curl \
  php-cli php-common php-zip php-gd php7-static php7-dev \ 
  php-xml php-pear php-bcmath php-json php-pdo php-mysqlnd php-pgsql \ 
  php-mbstring  php-soap php-sockets php7-pecl-redis php7-pecl-mcrypt php7-pecl-apcu \
  php7-json php7-ctype php7-exif php7-mysqli php7-iconv php7-fileinfo php7-pdo_mysql \
  php7-pecl-memcache php7-pecl-memcached php7-dom php7-intl php7-simplexml php7-xmlrpc \
  php7-tokenizer php7-pecl-imagick php7-pecl-apcu php7-ftp

#COPY conf/psol/php-7.4.14.tar.gz /tmp
#USER root
#RUN cd /tmp \
#  && docker-php-ext-configure dom \
#  && docker-php-ext-install -j$(nproc) dom \
#  && docker-php-ext-enable dom \
#  && docker-php-ext-configure intl \
#  && docker-php-ext-install intl \
#  && docker-php-ext-enable intl \
#  && docker-php-ext-configure xml \
# && docker-php-ext-install xml\
#  && docker-php-ext-enable xml \
#wget https://www.php.net/distributions/php-7.4.14.tar.gz && \
# tar -xzvf php-7.4.14.tar.gz && \
# cd php-7.4.14/ext/intl && \
# phpize && \
# ./configure && \
#make && \
# cp .libs/intl.so /usr/lib/php7/modules/ && \
# echo "extension=intl.so" >> /etc/php7/conf.d/00_intl.ini 


#RUN cd /tmp/php-7.4.14/ext/simplexml && \
#  phpize && \
#  ./configure && \
#  make && \
#  cp .libs/simplexml.so /usr/lib/php7/modules/ && \
# echo "extension=simplexml.so" >> /etc/php7/conf.d/00_simplexml.ini 
#RUN cd /tmp/php-7.4.14/ext/xmlrpc && \
#  phpize && \
#  ./configure && \
#  make && \
#  cp .libs/xmlrpc.so /usr/lib/php7/modules/ && \
#  echo "extension=xmlrpc.so" >> /etc/php7/conf.d/00_xmlrpc.ini 

#RUN cd /tmp/php-7.4.14/ext/tokenizer && \
#  phpize && \
#  ./configure && \
#  make && \
#  cp .libs/tokenizer.so /usr/lib/php7/modules/ && \
#  echo "extension=tokenizer.so" >> /etc/php7/conf.d/00_tokenizer.ini 


RUN apk add --no-cache --update --upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  php7-xmlwriter php7-xmlreader
# Install composer globally php7-intl php7-intl-7.4.12-r1
RUN apk add --no-cache 	composer  
#&& docker-php-ext-configure intl \
#&& docker-php-ext-install intl

ENV PATH="/usr/bin:${PATH}"
#RUN pecl channel-update pecl.php.net
#RUN pecl install redis
#RUN pecl install memcached
#RUN pecl install APCu
#RUN pecl install imagick 
#RUN docker-php-ext-enable memcached \
#  && docker-php-ext-enable redis \
#  && docker-php-ext-enable dom \
#  && docker-php-ext-enable xml \
#&& docker-php-ext-enable simplexml \
#  && docker-php-ext-enable xmlrpc \
#  && docker-php-ext-enable tokenizer 
RUN pecl channel-update pecl.php.net

RUN apk --no-cache upgrade && \
  scanelf --needed --nobanner --format '%n#p' /usr/lib/php7/modules/*.so \
  | tr ',' '\n' \
  | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  | xargs apk add --no-cache --update --upgrade --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
  && \
  apk add --no-cache tzdata && \
  apk del .build-deps

RUN addgroup -S nginx --gid 2021
RUN adduser -u 2020 -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN install -g nginx -o nginx -d /var/cache/ngx_pagespeed && \
  mkdir -p /var/log/nginx && \
  mkdir -p /opt/apache/adbs && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log

COPY conf/static /usr/share/nginx/html
COPY conf/nginx_conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx_conf/conf.d /etc/nginx/conf.d

# Configure PHP-FPM
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} \
  && sed -i -e "s/memory_limit\s*=\s*.*/memory_limit = 512M/g" ${php_conf} \
  && sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} \
  && sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} \
  && sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} \
  && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf \
  && sed -i -e "s|listen\s*=\s*127.0.0.1:9000|listen=/run/php-fpm.sock|g" ${fpm_conf} \
  && sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} \
  && sed -i -e "s/pm.max_children = 5/pm.max_children = 10/g" ${fpm_conf} \
  && sed -i -e "s/pm.start_servers = 2/pm.start_servers = 4/g" ${fpm_conf} \
  && sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 3/g" ${fpm_conf} \
  && sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 5/g" ${fpm_conf} \
  && sed -i -e "s/;pm.max_requests = 500/pm.max_requests = 1000/g" ${fpm_conf} \
  && sed -i -e "s/;pm.max_requests\s*=\s*1000/pm.max_requests = 1000/g" ${fpm_conf} \
  && sed -i -e "s/www-data/nginx/g" ${fpm_conf} \
  && sed -i -e "s/nobody/nginx/g" ${fpm_conf} \
  && sed -i -e "s/^;clear_env = no$/clear_env = no/" ${fpm_conf} \
  && sed -i -e "s|session.save_handler\s*=\s*files|session.save_handler = redis|g" ${php_conf} \
  && sed -i -e 's|;session.save_path\s*=\s*"/tmp"|session.save_path = tcp://rho-redis:6379|g' ${php_conf}

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nginx.nginx /run && \
  chown -R nginx.nginx /var/log/nginx && \
  chown -R nginx.nginx /var/log/php7 && \
  chown -R nginx.nginx /var/run 


RUN chown -R nginx.nginx /usr/share/nginx/html && \
  chown -R nginx.nginx /opt/apache/adbs

RUN rm -rf /tmp/*  
COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
RUN chmod +x /tmp/docker-entrypoint.sh

# Switch to use a non-root user from here on
USER nginx

EXPOSE 8080

STOPSIGNAL SIGTERM

CMD ["/bin/sh", "/tmp/docker-entrypoint.sh"]