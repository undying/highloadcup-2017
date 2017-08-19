#! /bin/bash -x

NGINX_OPTIONS="-p /etc/nginx"

for f in /etc/my_init.d/*;do
  test -x ${f} && bash -x ${f}
done


nginx ${NGINX_OPTIONS} -t && exec nginx ${NGINX_OPTIONS} -g 'daemon off;'

