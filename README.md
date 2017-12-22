# Docker for Bitbucket Pipeline with Laravel + PostGIS
This Docker is intended for automated test using Bitbucket Pipeline. Script is based on Laravel Homestead [provisioner](https://github.com/laravel/settler) without unnecessary parts

Based on `ubuntu:xenial`

With
- `nginx` and `php-fpm` from default repo
- `php7.1` from `ppa:ondrej/php`
- `PostgreSQL-10` and `PostGIS-2.4` from `apt.postgresql.org`
- `NodeJS 8.x` from `deb.nodesource.com`
- `redis`, `sqlite`, `memcached`, `beanstalkd` from default repo

## Note on Bitbucket Pipeline
The Pipeline overrides/ignores `ENTYRPOINT` and `CMD` part of `Dockerfile`, 
we have to manually run the service(s) of our container

example `bitbucket-pipelines.yml`
```
image: blackpaw/bitbucket-pipeline-laravel-postgis

pipelines:
  branches:
    master:
      - step:
          caches:
            - composer
            - node
          script:
            - service postgresql start
            - service php7.1-fpm start
            - service nginx start
            - composer install --no-progress --no-suggest --prefer-dist
            - npm install
            - php artisan key:generate
            - php artisan migrate
            - sh test
```
