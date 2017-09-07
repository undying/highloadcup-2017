
FROM debian:8
CMD [ "/sbin/init.sh" ]

### Nginx and Nginx plugins ###
ENV nginx_v=1.13.4 ndk_v=0.3.0
ENV lua_v=5.1.5 luajit_v=2.1.0-beta3 luarocks_v=2.4.2 lua_cjson_v=2.1.0 lua_module_v=0.10.10
ENV redis_server_v=4.0.1
ENV redis_lua_v=2.0.4 luasocket_v=2.0.2
ENV lua_resty_redis_v=0.26
ENV systemtap_v=3.1
###
ENV LUA_LIB=/usr/local/lib/ LUA_INC=/usr/local/include LUAJIT_LIB=/usr/local/lib LUAJIT_INC=/usr/local/include/luajit-2.1
###
### Dependencies ###
ENV build_deps="wget ca-certificates git cmake build-essential" runtime_deps="unzip"
ENV nginx_build_deps="libpcre3-dev libssl-dev"
ENV lua_build_deps="libreadline-dev libncurses5-dev"
ENV systemtap_build_deps="zlib1g-dev libdw-dev" systemtap_deps="libfindbin-libs-perl elfutils gettext python"
###

RUN set -x \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& export DEBIAN_CODENAME=$(sed -ne 's,VERSION=.*(\([a-z]\+\))",\1,p' /etc/os-release) \
	\
	&& sed -i 's|deb.debian.org|mirror.yandex.ru|' /etc/apt/sources.list \
	&& sed -i 's|security.debian.org|mirror.yandex.ru/debian-security|' /etc/apt/sources.list \
	\
	&& printf "deb http://deb.debian.org/debian experimental main contrib non-free\n" >> /etc/apt/sources.list \
	&& printf "deb http://deb.debian.org/debian jessie-backports main\n" >> /etc/apt/sources.list.d/backports.list \
	\
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    --no-install-recommends \
    --no-install-suggests \
    ${runtime_deps} \
    ${build_deps} \
    ${nginx_build_deps} \
    ${lua_build_deps} \
    ${systemtap_deps} ${systemtap_build_deps} \
  \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
  && echo "donwloading and unpacking build dependencies" \
  && cd /opt/ && printf "\
    http://nginx.org/download/nginx-${nginx_v}.tar.gz\n \
    https://www.lua.org/ftp/lua-${lua_v}.tar.gz\n \
    http://luajit.org/download/LuaJIT-${luajit_v}.tar.gz\n \
    https://luarocks.github.io/luarocks/releases/luarocks-${luarocks_v}.tar.gz\n \
    https://www.kyne.com.au/~mark/software/download/lua-cjson-${lua_cjson_v}.tar.gz\n \
    http://download.redis.io/releases/redis-${redis_server_v}.tar.gz\n \
    http://files.luaforge.net/releases/luasocket/luasocket/luasocket-${luasocket_v}/luasocket-${luasocket_v}.tar.gz\n \
    https://sourceware.org/systemtap/ftp/releases/systemtap-${systemtap_v}.tar.gz\n \
    https://github.com/openresty/lua-resty-redis/archive/v${lua_resty_redis_v}.tar.gz\n \
    https://github.com/nrk/redis-lua/archive/v${redis_lua_v}.tar.gz\n \
    https://github.com/simpl/ngx_devel_kit/archive/v${ndk_v}.tar.gz\n \
    https://github.com/openresty/lua-nginx-module/archive/v${lua_module_v}.tar.gz\n" \
    |xargs -P ${CPU_COUNT} -L1 -I{} wget --quiet {} \
  && ls *.gz|xargs -P ${CPU_COUNT} -L1 -I{} tar xzpf {} \
  && rm -v *.gz \
  && ls \
  \
  && echo "building the LuaJIT" \
  && cd /opt/LuaJIT-${luajit_v} \
  && make CCDEBUG=-g -j${CPU_COUNT} \
  && make install \
  \
  && echo "Building Lua" \
  && cd /opt/lua-${lua_v} \
  && make -j${CPU_COUNT} linux \
  && make test \
  && make install \
  \
  && echo "Building LuaRocks" \
  && cd /opt/luarocks-${luarocks_v} \
  && ./configure \
  && make -j ${CPU_COUNT} build \
  && make install \
  \
  && echo "Installing Lua Packages" \
  && luarocks install inspect \
  \
  && echo "Building Lua cjson" \
  && cd /opt/lua-cjson-${lua_cjson_v} \
  && make CFLAGS="-O3" -j${CPU_COUNT} \
  && luarocks make \
  \
  && echo "Building Redis Server" \
  && cd /opt/redis-${redis_server_v} \
  && make CFLAGS="-O3" -j${CPU_COUNT}\
  && make install \
  \
  && echo "Building LuaSocket for Redis Client" \
  && cd /opt/luasocket-${luasocket_v} \
  && make -j${CPU_COUNT} \
  && make install \
  \
  && echo "Building Redis Lua Client" \
  && cd /opt/redis-lua-${redis_lua_v} \
  && install ./src/redis.lua /usr/local/share/lua/5.1/ \
  \
  && echo "Building Resty Lua Redis Client" \
  && cd /opt/lua-resty-redis-${lua_resty_redis_v} \
  && install lib/resty/redis.lua /usr/local/share/lua/5.1/resty_redis.lua \
  \
  && export CPU_COUNT=$(grep -c processor /proc/cpuinfo) \
  && echo "Building Nginx" \
  && cd /opt/nginx-${nginx_v} \
  && ./configure \
    --with-debug \
    --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    \
    --user=nginx --group=nginx \
    \
    --with-cc-opt="-O3 -g" \
    \
    --with-ipv6 \
    --with-pcre-jit \
    --with-threads \
    \
    --add-module="/opt/ngx_devel_kit-${ndk_v}" \
    --add-module="/opt/lua-nginx-module-${lua_module_v}" \
    \
  && make -j${CPU_COUNT} \
  && make install \
  \
  && useradd --user-group --system nginx \
  && install -d -o nginx -g nginx /var/cache/nginx/ \
  && install -d -o nginx -g nginx /etc/nginx/ /var/www/ \
  && nginx -V \
  \
  && echo "Building Systemtap" \
  && cd /opt/systemtap-${systemtap_v} \
  && ./configure CFLAGS="-g -O2" \
    --prefix=/usr/local \
    --disable-docs \
    --disable-publican \
    --disable-refdocs \
  && make -j ${CPU_COUNT} \
  && make install \
  \
  && echo "Removing Misc Packages" \
  \
  && apt-get autoremove -y \
    ${build_deps} \
    ${nginx_build_deps} \
    ${lua_build_deps} \
    ${systemtap_build_deps} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/logrotate.d/* /opt/*

COPY root/ /

