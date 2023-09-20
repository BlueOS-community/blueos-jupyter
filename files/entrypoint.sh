#!/bin/bash

# turn on bash's job control
set -m
read NGINX_PORT JUPYTER_PORT <<< $(python -c 'import socket; s1=socket.socket(); s1.bind(("", 0)); s2=socket.socket(); s2.bind(("", 0)); print(str(s1.getsockname()[1]) + " " + str(s2.getsockname()[1])); s1.close(); s2.close()')
echo "Free ports: $NGINX_PORT $JUPYTER_PORT"
sed -i "s/NGINX_PORT/$NGINX_PORT/g; s/JUPYTER_PORT/$JUPYTER_PORT/g" /etc/nginx/nginx.conf
echo "Starting nginx.."
nginx &

[ ! -d "/root/examples" ] && cp -r /tmp/examples /root/examples
echo "Starting our application.."
jupyter lab --ip=0.0.0.0 --port=$JUPYTER_PORT \
  --no-browser \
  --notebook-dir '/root/' \
  --allow-root \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  --NotebookApp.allow_origin='*' \
  --NotebookApp.allow_remote_access=True \
  --NotebookApp.trust_xheaders=True
