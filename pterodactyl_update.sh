#!/bin/bash

#THIS IS A EARLY STAGE OF THIS SCRIPT, MORE PART GOING TO BE ADDED LIKE CENTOS SUPPORT!

export PYTHONIOENCODING=utf8
#EDITABLE PART

PATH_TO_PANEL_WEB='/var/www/pterodactyl'
PATH_TO_WINGS_SERVICE='/usr/local/bin'

#DO NOT EDIT UNLESS IF YOU KNOW WAHTA ARE YOU DOING!
export PYTHONIOENCODING=utf8
panel_version=$(curl -s 'https://api.github.com/repos/pterodactyl/panel/releases/latest' | \
    python2 -c "import sys, json; print json.load(sys.stdin)['tag_name']")
wings_version=$(curl -s 'https://api.github.com/repos/pterodactyl/wings/releases/latest' | \
    python2 -c "import sys, json; print json.load(sys.stdin)['tag_name']")
echo "Panel latest version: "$panel_version
echo "Wings latest version: "$wings_version
echo "Running update script"
echo "Putting site on 503 page and updating!"
cd $PATH_TO_PANEL_WEB
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
echo "Updating Wings service"
cd $PATH_TO_WINGS_SERVICE
curl -L -o $PATH_TO_WINGS_SERVICE/wings https://github.com/pterodactyl/wings/releases/download/$wings_version/wings_linux_amd64
chmod u+x $PATH_TO_WINGS_SERVICE/wings
systemctl restart wings
echo "Updated! have a nice day. If the wings service does not start up restart the server!"
