#!/bin/bash
set -eo pipefail

[[ "${DEBUG}" == true ]] && set -x

initialize_system() {
    echo "Initializing Piplin container ..."

    APP_ENV=${APP_ENV:-development}
    APP_DEBUG=${APP_DEBUG:-true}
    DB_CONNECTION=${DB_CONNECTION:-mysql}
    DB_HOST=${DB_HOST:-piplin-mysql}
    DB_DATABASE=${DB_DATABASE:-piplin}
    DB_PREFIX=${DB_PREFIX}
    DB_USERNAME=${DB_USERNAME:-piplin}
    DB_PASSWORD=${DB_PASSWORD:-piplinpassword}

    if [[ "${DB_CONNECTION}" = "mysql" ]]; then
        DB_PORT=${DB_PORT:-3306}
    fi

    DB_PORT=${DB_PORT}

    # configure env file
    sed 's,{{APP_ENV}},'"${APP_ENV}"',g' -i /var/www/piplin/.env
    sed 's,{{APP_DEBUG}},'"${APP_DEBUG}"',g' -i /var/www/piplin/.env
}

init_db() {
    echo "Initializing Piplin database ..."
    redis-server &
    php artisan migrate
    php artisan db:seed
    redis-cli shutdown
}

start_system() {
    initialize_system
    init_db
    echo "Starting Piplin! ..."
    php artisan config:cache
    /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

start_system

exit 0
