# Docker for Bitbucket Pipeline with Laravel + PostGIS
This Docker is intended for automated test using Bitbucket Pipeline. Script is based on Laravel Homestead [provisioner](https://github.com/laravel/settler) without unnecessary parts

Based on `ubuntu:xenial`

With
- `nginx` and `php-fpm` from default repo
- `php7.1` from `ppa:ondrej/php`
- `PostgreSQL-10` and `PostGIS-2.4` from `apt.postgresql.org`
- `NodeJS 8.x` with `grunt-cli`, `gulp`, `bower`
   from `deb.nodesource.com`
- `redis`, `sqlite`, `memcached`, `beanstalkd` from default repo
