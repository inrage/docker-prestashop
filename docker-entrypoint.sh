#!/bin/bash
set -e

chown -R www-data:www-data /var/www/html/var \
                           /var/www/html/cache \
                           /var/www/html/log \
                           /var/www/html/upload \
                           /var/www/html/img \
                           /var/www/html/config 2>/dev/null || true

mkdir -p /var/www/html/var/cache \
         /var/www/html/var/logs \
         /var/www/html/upload \
         /var/www/html/img/tmp

exec apache2-foreground
