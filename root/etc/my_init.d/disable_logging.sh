#! /bin/bash

exit

NGINX_CONF=/etc/nginx/nginx.conf
DISABLE_LOGGING=1


for f in /tmp/data/options.txt /tmp/data_unpack/options.txt;do
  [ -e "${f}" ] || continue
  DISABLE_LOGGING=$(awk '{if(NR == 2) {print $0}}' ${f})
done

[ ${DISABLE_LOGGING} -eq 1 ] || exit

sed -i 's,access_log .*,access_log off;,g' ${NGINX_CONF}
sed -i 's,error_log .*,error_log off;,g' ${NGINX_CONF}

