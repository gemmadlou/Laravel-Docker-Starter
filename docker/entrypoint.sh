#!/bin/sh -e
# Alpine shell is `sh`
# Provision the environment in here!

echo "Starting app entrypoint..."

case $1 in

  permissions)
    cd /var/www

    echo "Ensuring laravel logs directory existence and permissions..."
    mkdir -p /storage/logs
    mkdir -p /storage/app/public
    mkdir -p /storage/framework/cache
    mkdir -p /storage/framework/sessions
    mkdir -p /storage/framework/testing
    mkdir -p /storage/framework/views
    chown -R 1000:1000 /storage
    chmod -R 0777 /storage
  ;;

  decache)
    echo "Decaching"
      php artisan cache:clear
      php artisan config:clear
      php artisan view:clear
  ;;

  db:refresh)
    php artisan migrate:refresh --seed
    php artisan ide-helper:models --nowrite # Has to be run with access to DB
  ;;

  db:migrate)
    php artisan migrate
  ;;

  server)
    ./$0 permissions
    ./$0 decache
    ./$0 db:migrate

    php-fpm
  ;;

  optimize)
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
  ;;

  queue)
    ./$0 permissions
    ./$0 decache
    ./$0 db:migrate

    php artisan queue:work
  ;;

  *)
    echo "Running container commands..."
    exec "$@"
  ;;

esac

exit 0
