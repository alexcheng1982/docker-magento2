# Docker image for Magento 2

[![](https://images.microbadger.com/badges/image/alexcheng/magento2.svg)](http://microbadger.com/images/alexcheng/magento2)

[![Docker build](http://dockeri.co/image/alexcheng/magento2)](https://hub.docker.com/r/alexcheng/magento2/)

This repo converts the [long installation guide](http://devdocs.magento.com/guides/v1.0/install-gde/bk-install-guide.html) of Magento 2 into simple Docker image to use. It uses the same convention as my [Docker image for Magento 1.x](https://github.com/alexcheng1982/docker-magento).

For documentation, please refer to the Magento 1.x [repo](https://github.com/alexcheng1982/docker-magento). These two Docker images follow the same instructions. 

**Please note: this Docker image is for development and testing only, not for production use. Setting up a Magento 2 production server requires more configurations. Please refer to [official documentations](http://devdocs.magento.com/guides/v2.2/config-guide/deployment/).**

Below are some basic instructions.

## Quick start

The easiest way to start Magento 2 with MySQL is using [Docker Compose](https://docs.docker.com/compose/). Just clone this repo and run following command in the root directory. The default `docker-compose.yml` uses MySQL and phpMyAdmin.

~~~
$ docker-compose up -d
~~~

For admin username and password, please refer to the file `env`. You can also update the file `env` to update those configurations. Below are the default configurations.

~~~
MYSQL_HOST=db
MYSQL_ROOT_PASSWORD=myrootpassword
MYSQL_USER=magento
MYSQL_PASSWORD=magento
MYSQL_DATABASE=magento

MAGENTO_LANGUAGE=en_GB
MAGENTO_TIMEZONE=Pacific/Auckland
MAGENTO_DEFAULT_CURRENCY=NZD
MAGENTO_URL=http://local.magento

MAGENTO_ADMIN_FIRSTNAME=Admin
MAGENTO_ADMIN_LASTNAME=MyStore
MAGENTO_ADMIN_EMAIL=amdin@example.com
MAGENTO_ADMIN_USERNAME=admin
MAGENTO_ADMIN_PASSWORD=magentorocks1
~~~

For example, if you want to change the default currency, just update the variable `MAGENTO_DEFAULT_CURRENCY`, e.g. `MAGENTO_DEFAULT_CURRENCY=USD`.

## Installation

After starting the container, you'll see the setup page of Magento 2. You can use the script `install-magento` to quickly install Magento 2. The installation script uses the variables in the `env` file.

### Magento 2

~~~
$ docker exec -it <container_name> install-magento
~~~

### Sample data

**Please note** Not working for Magento 2.2.0 yet.

~~~
$ docker exec -it <container_name> install-sampledata
~~~

### Database

The default `docker-compose.yml` uses MySQL as the database and starts [phpMyAdmin](https://www.phpmyadmin.net/). The default URL for phpMyAdmin is `http://localhost:8085`. Use MySQL username and password to log in.

## FAQ

### Where is the database?

Magento 2 cannot run with a database. This image is for Magento 2 only. It doesn't contain MySQL server. MySQL server should be started in another container and linked with Magento 2 container. It's recommended to use Docker Compose to start both containers. You can also use [Kubernetes](https://kubernetes.io/) or other tools.

### Why accessing http://local.magento?

For development and testing in the local environment, using `localhost` as Magento 2 URL has some issues. The default `env` file use `http://local.magento` as the value of `MAGENTO_URL`. You need to [edit your `hosts` file](https://support.rackspace.com/how-to/modify-your-hosts-file/) to add the mapping from `local.magento` to `localhost`. You can use any domain names as long as it looks like a real domain, not `localhost`.

### How to update Magento 2 installation configurations?

Depends on how the container is used,

* When using the GUI setup page of Magento 2, update configurations in the UI.
* When using the script, update configurations in the `env` file. 
* When starting Magento 2 as a standalone container, use `-e` to pass environment variables.
