#!/bin/bash
export PYTHONIOENCODING=utf8
panel_version=$(curl -s 'https://api.github.com/repos/pterodactyl/panel/releases/latest' | \
    python2 -c "import sys, json; print json.load(sys.stdin)['tag_name']")
wings_version=$(curl -s 'https://api.github.com/repos/pterodactyl/wings/releases/latest' | \
    python2 -c "import sys, json; print json.load(sys.stdin)['tag_name']")
echo "Panel latest version: "$panel_version
echo "Wings latest version: "$wings_version
echo "Running update script"
echo "Putting site on 503 page and updating!"
cd /var/www/pterodactyl
php artisan down
curl -L https://github.com/pterodactyl/panel/releases/download/$panel_version/panel.tar.gz | tar -xzv
chmod -R 755 storage/* bootstrap/cache
composer install --no-dev --optimize-autoloader
php artisan view:clear
php artisan config:clear
php artisan migrate --force
php artisan db:seed --force
chown -R www-data:www-data *
php artisan up
#echo "Updating Wings service"
cd /usr/local/bin
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/$wings_version/wings_linux_amd64
chmod u+x /usr/local/bin/wings
systemctl restart wings
echo "Updated! have a nice day. If the wings service does not start up restart the server!"
