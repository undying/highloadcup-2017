#! /bin/bash -x

for f in /etc/my_init.d/*;do
  test -x ${f} && bash -x ${f}
done


/sbin/run_redis.sh
/sbin/run_import.sh

/sbin/run_nginx.sh

