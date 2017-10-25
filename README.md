# Docker image for Magento 2

[![](https://images.microbadger.com/badges/image/alexcheng/magento2.svg)](http://microbadger.com/images/alexcheng/magento2)

[![Docker build](http://dockeri.co/image/alexcheng/magento2)](https://hub.docker.com/r/alexcheng/magento2/)

This repo converts the [long installation guide](http://devdocs.magento.com/guides/v1.0/install-gde/bk-install-guide.html) of Magento 2 into simple Docker image to use. It uses the same convention as my [Docker image for Magento 1.x](https://github.com/alexcheng1982/docker-magento).

For documentation, please refer to the Magento 1.x [repo](https://github.com/alexcheng1982/docker-magento). These two Docker images follow the same instructions. 

Below are some basic instructions.

## Quick start

The easiest way to start using Magento 2 is [Docker Compose](https://docs.docker.com/compose/).

~~~
$ docker-compose up -d
~~~

For admin username and password, please refer to the file `env`. You can also update the file `env` to update those configurations.

## Installation

### Sample data

**Please note** Not working for Magento 2.2.0 yet.

~~~
$ docker exec -it <container_name> install-sampledata
~~~

### Magento 2

~~~
$ docker exec -it <container_name> install-magento
~~~

### DB

The default `docker-compose.yml` uses MySQL as the database and starts [phpMyAdmin](https://www.phpmyadmin.net/). The default URL for phpMyAdmin is `http://localhost:8085`. Use MySQL username and password to log in.