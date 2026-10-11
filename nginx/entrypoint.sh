#!/bin/sh
set -e
envsubst '${DOMAIN}' \
    < /etc/nginx/conf.d/nginx.conf.template \
    > /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'
