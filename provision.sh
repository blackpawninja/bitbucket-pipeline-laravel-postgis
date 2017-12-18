#!/usr/bin/env bash

# Update Package List
apt-get update
apt-get upgrade -y

# Basic packages
apt-get install -y sudo software-properties-common nano curl wget \
build-essential dos2unix gcc git git-flow libmcrypt4 libpcre3-dev apt-utils \
make python2.7-dev python-pip re2c supervisor unattended-upgrades whois zip unzip

# Force Locale
apt-get install -y locales
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

# Enable Services
export RUNLEVEL=1
echo exit 0 > /usr/sbin/policy-rc.d

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP Repo
apt-add-repository ppa:ondrej/php -y

# PostgreSQL Repo
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

# Update Package Lists
apt-get update

# PostgreSQL + PostGIS
apt-get install -y postgresql-10-postgis-2.4

# PHP 7.1
apt-get install -y php7.1-cli php7.1-dev \
php7.1-pgsql php7.1-sqlite3 php7.1-soap \
php7.1-json php7.1-curl php7.1-gd \
php7.1-gmp php7.1-imap php7.1-mcrypt \
php7.1-mbstring php7.1-zip \
php-pear php-apcu php-memcached php-redis

# Nginx & PHP-FPM
apt-get install -y nginx php-fpm

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path
export PATH="/home/homestead/.composer/vendor/bin:$PATH"

# Set Some PHP CLI Settings
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

sed -i "s/.*daemonize.*/daemonize = no/" /etc/php/7.1/fpm/php-fpm.conf
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

# Set The Nginx & PHP-FPM User
sed -i '1 idaemon off;' /etc/nginx/nginx.conf
#sed -i "s/user www-data;/user homestead;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

mkdir -p /run/php
touch /run/php/php7.1-fpm.sock
#sed -i "s/user = www-data/user = homestead/" /etc/php/7.1/fpm/pool.d/www.conf
#sed -i "s/group = www-data/group = homestead/" /etc/php/7.1/fpm/pool.d/www.conf
#sed -i "s/;listen\.owner.*/listen.owner = homestead/" /etc/php/7.1/fpm/pool.d/www.conf
#sed -i "s/;listen\.group.*/listen.group = homestead/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf

# Install Node
curl --silent --location https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs
npm install -g grunt-cli
npm install -g gulp
npm install -g bower

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

# Memcached
apt-get install -y memcached

# Beanstalkd
apt-get install -y beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

# Redis
apt-get install -y redis-server
sed -i "s/daemonize yes/daemonize no/" /etc/redis/redis.conf

# Configure default nginx site
DOCROOT=$BITBUCKET_CLONE_DIR

block="server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root $DOCROOT;
    server_name localhost;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/app-error.log error;

    error_page 404 /index.php;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

cat > /etc/nginx/sites-enabled/default
echo "$block" > "/etc/nginx/sites-enabled/default"
