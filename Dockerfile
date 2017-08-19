
FROM debian:8
CMD [ "/sbin/init.sh" ]

### Nginx and Nginx plugins ###
ENV openresty_v=1.11.2.4
###
ENV PATH=/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:${PATH}
###

RUN set -x \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& export DEBIAN_CODENAME=$(sed -ne 's,VERSION=.*(\([a-z]\+\))",\1,p' /etc/os-release) \
	\
	&& sed -i 's|deb.debian.org|mirror.yandex.ru|' /etc/apt/sources.list \
	&& sed -i 's|security.debian.org|mirror.yandex.ru/debian-security|' /etc/apt/sources.list \
	\
	&& printf "deb http://ftp.ru.debian.org/debian experimental main contrib non-free\n" >> /etc/apt/sources.list \
	&& printf "deb http://ftp.debian.org/debian jessie-backports main\n" >> /etc/apt/sources.list.d/backports.list \
	\
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    --no-install-recommends \
    --no-install-suggests \
    wget \
    ca-certificates \
    \
    git \
    cmake \
    build-essential \
    \
    libpcre3-dev \
    libssl-dev \
  \
  && echo "donwloading and unpacking build dependencies" \
  && cd /opt/ && printf "\
    https://openresty.org/download/openresty-${openresty_v}.tar.gz\n" \
    |xargs -P ${CPU_COUNT} -L1 -I{} wget --quiet {} \
  && ls *.gz|xargs -P ${CPU_COUNT} -L1 -I{} tar xzpf {} \
  && rm -v *.gz \
  \
  && echo "Building OpenResty" \
  \
  && cd /opt/openresty-${openresty_v} \
  && ./configure -j${CPU_COUNT} \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx --group=nginx \
    --with-pcre-jit \
    --with-threads \
    --with-ipv6 \
    \
    --without-http_xss_module \
    --without-http_coolkit_module \
    --without-http_set_misc_module \
    --without-http_form_input_module \
    --without-http_encrypted_session_module \
    --without-http_srcache_module \
    --without-http_headers_more_module \
    --without-http_array_var_module \
    --without-http_memc_module \
    --without-http_redis2_module \
    --without-http_redis_module \
    --without-http_rds_json_module \
    --without-http_rds_csv_module \
  \
  && make -j${CPU_COUNT} \
  && make install \
  \
  && useradd --user-group --system nginx \
  && install -d -o nginx -g nginx /var/cache/nginx/ \
  && install -d -o nginx -g nginx /etc/nginx/ /var/www/ \
  && nginx -V \
  && rm -rf /etc/nginx/* \
  \
  && echo "Removing Misc Packages" \
  \
  && apt-get autoremove -y \
    git \
    wget \
    cmake \
    build-essential \
    libpcre3-dev \
    libssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/logrotate.d/*

COPY root/ /

