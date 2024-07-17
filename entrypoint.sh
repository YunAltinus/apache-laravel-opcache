#!/bin/sh
set -e

# PHP-FPM için gerekli olan socket ve log dizinlerini oluştur
mkdir -p /run/php /var/log/php-fpm
chown -R www-data:www-data /var/log/php-fpm

# PHP dosya izinlerini kontrol et
chown -R www-data:www-data /var/www/html

# Supervisor için gerekli dosya izinlerini kontrol et
chown -R root:root /etc/supervisor
chmod -R 755 /etc/supervisor

# Uygulama ortamını belirle ve önbellek temizleme işlemlerini yap
if [ "$APP_ENV" = "production" ]; then
  echo "Running in production mode"
  php artisan config:cache --no-ansi -q
  php artisan route:cache --no-ansi -q
  php artisan view:cache --no-ansi -q
else
  echo "Running in development mode"
  php artisan config:clear --no-ansi -q
  php artisan route:clear --no-ansi -q
  php artisan view:clear --no-ansi -q
fi

# Gereksinim duyulan diğer başlangıç komutları
# Veritabanı migrasyonları vb. işlemler yapılabilir

# Supervisor'i başlat
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
