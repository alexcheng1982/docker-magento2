# Docker Image for Magento Open Source 2

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/alexcheng1982)

**This repo ONLY maintains Docker images for Magento Open Source 2.4.x. You may still found Docker images for old versions in the [old registry](https://quay.io/repository/alexcheng1982/magento2).**

**Starting from Magento 2.4.x, container images are now hosted in [GitHub Container Registry](https://github.com/alexcheng1982/docker-magento2/pkgs/container/docker-magento2).**

This repo provides Docker images for different Magento 2.4 versions. Refer to [this page](https://github.com/alexcheng1982/docker-magento2/pkgs/container/docker-magento2/versions) to see all available versions.

| Version    | PHP Version | Container image                                  |
| ---------- | ----------- | ------------------------------------------------ |
| `2.4.6-p3` | `8.1`       | `ghcr.io/alexcheng1982/docker-magento2:2.4.6-p3` |
| `2.4.5-p5` | `8.1`       | `ghcr.io/alexcheng1982/docker-magento2:2.4.5-p5` |
| `2.4.4-p6` | `8.1`       | `ghcr.io/alexcheng1982/docker-magento2:2.4.4-p6` |

This docker image is based on my [docker-apache2-php8](https://github.com/alexcheng1982/docker-apache2-php8) image for Apache 2 and PHP 8. Please refer to the image label `php_version` for the actual PHP version. In general, Magento uses PHP `8.1` starting from `2.4.4`. Versions `2.4.2` and `2.4.3` use PHP `7.4`. Please refer to the label `php_version` of the image to get the actual PHP version.

> This docker image is based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) with Ubuntu 22.04 LTS. The reason to use `phusion/baseimage-docker` is to support multiple processes, which is important to get cronjobs working in Magento.

**Please note: this Docker image is for Magento 2 related development and testing only, not ready for production use. Setting up a Magento 2 production server requires more configurations. You can use this image as the base to build customized images.**

## Magento 2 Installation Types

Magento 2.4 can be installed using [Composer](https://getcomposer.org/) or git. The git-based installation mode is used for contributor of Magento. This Docker image uses Composer as the installation type, so the **Web Setup Wizard** can be used. 

Below are some basic instructions.

## Quick Start

The easiest way to start Magento 2 with MySQL is using [Docker Compose](https://docs.docker.com/compose/). Just clone this repo and run the following command in the directory of a specific version. For example, go to `versions/2.4.6-p3` for Magento `2.4.6-p3`.

The default `docker-compose.yaml` uses MySQL, phpMyAdmin, and OpenSearch.

~~~
$ docker compose up -d
~~~

For admin username and password, please refer to the file `env`. You can also change the file `env` to update those configurations. Below are the default configurations.

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
MAGENTO_BACKEND_FRONTNAME=admin
MAGENTO_USE_SECURE=0
MAGENTO_BASE_URL_SECURE=0
MAGENTO_USE_SECURE_ADMIN=0

MAGENTO_ADMIN_FIRSTNAME=Admin
MAGENTO_ADMIN_LASTNAME=MyStore
MAGENTO_ADMIN_EMAIL=amdin@example.com
MAGENTO_ADMIN_USERNAME=admin
MAGENTO_ADMIN_PASSWORD=magentorocks1

OPENSEARCH_HOST=opensearch
~~~

For example, if you want to change the default currency, just update the variable `MAGENTO_DEFAULT_CURRENCY`, e.g. `MAGENTO_DEFAULT_CURRENCY=USD`.

To get all the possible values of `MAGENTO_LANGUAGE`, `MAGENTO_TIMEZONE` and `MAGENTO_DEFAULT_CURRENCY`, run the corresponding command shown below:

| Variable                   | Command                          |
| -------------------------- | -------------------------------- |
| `MAGENTO_LANGUAGE`         | `bin/magento info:language:list` |
| `MAGENTO_TIMEZONE`         | `bin/magento info:timezone:list` |
| `MAGENTO_DEFAULT_CURRENCY` | `bin/magento info:currency:list` |

For example, to get all possible values of `MAGENTO_LANGUAGE`, run

```bash
$ docker run --rm -it ghcr.io/alexcheng1982/docker-magento2:2.4.6-p3 info:language:list
```

You can find all available options in the official [guide](https://experienceleague.adobe.com/docs/commerce-operations/configuration-guide/cli/common-cli-commands.html?lang=en). If you need more options, fork this repo and add them in `bin\install-magento`.

Please see the following video for a quick demo.

[![Use Magento 2 with Docker](https://img.youtube.com/vi/18tOf_cuQKg/hqdefault.jpg)](https://www.youtube.com/watch?v=18tOf_cuQKg "Use Magento 2 with Docker")

## Installation

After starting the container, you'll see the setup page of Magento 2. You can use the script `install-magento` to quickly install Magento 2. The installation script uses the variables in the `env` file. Use `docker ps` to find the container name.

### Magento 2

~~~
$ docker-compose exec web install-magento
~~~

### Sample data

~~~
$ docker-compose exec web install-sampledata
~~~


### Database

The default `docker-compose.yml` uses MySQL as the database and starts [phpMyAdmin](https://www.phpmyadmin.net/). The default URL for phpMyAdmin is `http://localhost:8580`. Use MySQL username and password to log in.

MySQL `8.0.0` is used as the default database version.

### Usage

After Magento 2 is installed, open a browser and navigate to `http://local.magento/`. For admin access, navigate to `http://local.magento/admin/` and log in using the admin username and password specified in the `env` file. Default admin username and password are `admin` and `magentorocks1`, respectively. Two-factor authentication is disabled.

### Running on Windows

When running on Windows, the port `80` may be occupied by built-in IIS or ASP.NET server. The following command finds ID of the process that occupies port `80`.

```
netstat -ano -p TCP | find /I"listening" | find /I"80"
```

Then `taskkill /F /PID <pid>` can be used to kill the process to free the port.

## FAQ

### How to update Magento 2 version?

To update Magento 2 version, fork this repository and modify `update.js`. In the `versions` array, add a new version with Magento 2 version number and PHP version. The base image [docker-apache2-php8](https://github.com/alexcheng1982/docker-apache2-php8) has PHP versions `8.1`, `8.2`, and `8.3`.

Run `update.js` using NodeJS. Files of the new version will be generated in directory `versions/<version_name>`. Run `docker build` in the version's directory to build the container image.

### How to use a different port?

If the default port `80` cannot be used for some reasons, you can change to a different port. Simply change the `MAGENTO_URL` from `http://local.magento` to add the port number, for example, `http://local.magento:8080`. You may also need to modify `docker-compose.yaml` file to update the exported port of the Magento container.

### How to keep installed Magento?

You can add a volume to folder `/var/www/html`, see the `docker-compose.yml` file.

```yaml
volumes: 
  - magento-data:/var/www/html 
```

### Where is the database?

Magento 2 cannot run without a database. This image is for Magento 2 only. It doesn't contain a MySQL server. A MySQL server should be started in another container and linked with Magento 2 container. It's recommended to use Docker Compose to start both containers. You can also use [Kubernetes](https://kubernetes.io/) or other tools.

### Why accessing http://local.magento?

For development and testing in the local environment, using `localhost` as Magento 2 URL has some issues. The default `env` file use `http://local.magento` as the value of `MAGENTO_URL`. You need to [edit your `hosts` file](https://support.rackspace.com/how-to/modify-your-hosts-file/) to add the mapping from `local.magento` to `localhost`. You can use any domain names as long as it looks like a real domain, not `localhost`.

If `localhost` doesn't work, try using `127.0.0.1`.

```
127.0.0.1    local.magento
```


### How to update Magento 2 installation configurations?

Depends on how the container is used,

* When using the GUI setup page of Magento 2, update configurations in the UI.
* When using the script, update configurations in the `env` file. 
* When starting Magento 2 as a standalone container, use `-e` to pass environment variables.

### Why getting access denied error after changing the default DB password?

If you change the default DB password in `env` file and get the access denied error when installing Magento 2, see [this issue comment](https://github.com/alexcheng1982/docker-magento2/issues/10#issuecomment-355382150).

## Develop and test using this Docker image

As I mentioned before, this Docker image is primarily used for development and testing. Depends on the tasks you are trying to do, there are different ways to use this Docker image.

### Extensions and themes

You can keep the extensions and themes directories on your local host machine, and use Docker Compose [volumes](https://docs.docker.com/compose/compose-file/#volumes) to install the extensions and themes. For example, if you have a theme in the directory `/dev/mytheme`, you can install it by specifying it in the `docker-composer.yaml` file. Then you can see the theme in Magento admin UI.

```yml
version: '3.0'
services:
  web:
    image: ghcr.io/alexcheng1982/docker-magento2:2.4.6-p3
    ports:
      - "80:80"
    links:
      - db
    env_file:
      - env
    volumes:
      - /dev/mytheme:/var/www/html/app/design/frontend/mytheme/default
```

### Modify Magento core files

If you want to modify Magento core files, you cannot modify them directly in the container. Those changes will be lost. It's also not recommended to update Magento core files directly, which makes upgrading Magento a painful process. Actually, Docker makes the process much easier if you absolutely need to modify some core files. You can use volumes to overwrite files.

For example, if you want to overwrite the file `app/code/Magento/Catalog/Block/Product/Price.php`, you can copy the content to a new file in your local directory `/dev/mycode/magento_2_2` and make the changes, then use `volumes` to overwrite it.

```yml
volumes:
  - /dev/mycode/magento_2_2/app/code/Magento/Catalog/Block/Product/Price.php:/var/www/html/app/code/Magento/Catalog/Block/Product/Price.php
```

By using Docker, we can make sure that all your changes to Magento core files are kept in one place and tracked in source code repository. These changes are also correctly aligned with different Magento versions.

When deploying those changes to production servers, we can simply copy all files in the `/dev/mycode/magento_2_2` directory to Magento installation directory and overwrite existing files.

### Test Magento compatibilities

This Docker images has different tags for corresponding Magento 2.4 versions. You can switch to different Magento versions very easily when testing extensions and themes.
