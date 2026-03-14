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

PARAMS_FILE="/var/www/html/app/config/parameters.php"

if [ -n "$PS_DB_HOST" ] && [ ! -f "$PARAMS_FILE" ]; then
    mkdir -p "$(dirname "$PARAMS_FILE")"
    cat > "$PARAMS_FILE" <<'EOPHP'
<?php return array(
    'parameters' => array(
        'database_host' => getenv('PS_DB_HOST') ?: '127.0.0.1',
        'database_port' => getenv('PS_DB_PORT') ?: '',
        'database_name' => getenv('PS_DB_NAME') ?: 'prestashop',
        'database_user' => getenv('PS_DB_USER') ?: 'prestashop',
        'database_password' => getenv('PS_DB_PASSWORD') ?: '',
        'database_prefix' => getenv('PS_DB_PREFIX') ?: 'ps_',
        'database_engine' => 'InnoDB',
        'mailer_transport' => 'smtp',
        'mailer_host' => getenv('PS_SMTP_HOST') ?: '127.0.0.1',
        'mailer_user' => getenv('PS_SMTP_USER') ?: null,
        'mailer_password' => getenv('PS_SMTP_PASSWORD') ?: null,
        'secret' => getenv('PS_SECRET') ?: 'change-me',
        'ps_caching' => 'CacheMemcache',
        'ps_cache_enable' => false,
        'ps_creation_date' => getenv('PS_CREATION_DATE') ?: '2020-01-01',
        'locale' => getenv('PS_LOCALE') ?: 'fr-FR',
        'cookie_key' => getenv('PS_COOKIE_KEY') ?: '',
        'cookie_iv' => getenv('PS_COOKIE_IV') ?: '',
        'new_cookie_key' => getenv('PS_NEW_COOKIE_KEY') ?: '',
    ),
);
EOPHP
    chown www-data:www-data "$PARAMS_FILE"
fi

exec apache2-foreground
