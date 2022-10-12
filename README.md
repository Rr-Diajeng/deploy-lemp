 # Vagrant LEMP

 ## **Contents**

- [Vagrant LEMP](#vagrant-lemp)
  - [**Contents**](#contents)
  - [Getting Started](#getting-started)
  - [Initialize](#initialize)
  - [Edit Vagrantfile](#edit-vagrantfile)
  - [Create Shell Provisioning](#create-shell-provisioning)
  - [Create Nginx configuration](#create-nginx-configuration)
  - [Upload Laravel project](#upload-laravel-project)
  - [Running the project](#running-the-project)
  - [Create new Database](#create-new-database)
  - [Create Application Environment](#create-application-environment)
    - [Add debug](#add-debug)
    - [Edit .env file](#edit-env-file)
  - [Composer](#composer)
    - [Composer Install](#composer-install)
    - [Composer Update(optional)](#composer-updateoptional)
    - [Upgrade Composer](#upgrade-composer)
  - [Artisan](#artisan)
  - [Some Errors](#some-errors)
    - [what appears is still the Nginx default page](#what-appears-is-still-the-nginx-default-page)
  - [Vagrant Destory](#vagrant-destory)

## Getting Started
Setup LEMP (Linux, Nginx, MySQL, and PHP) using Vagrant, build uses [gusztavvargadr/ubuntu-server](https://app.vagrantup.com/gusztavvargadr/boxes/ubuntu-server) Vagrant box for the official Ubuntu Server 20.04 LTS.

To running this project, you first need Vitualbox and Vagrant installed on your system. Visit the downloads pages below and follow the instructions for operating system:

 - [Virtualbox Download](https://www.virtualbox.org/wiki/Downloads)
 - [Vagrant Download](https://www.vagrantup.com/downloads)

## Initialize
Add this command to initializes your directory to be a Vagrant environment
```shell
vagrant init
```

## Edit Vagrantfile
Open your text editor to edit the Vagrantfile, and add this section.

```ruby
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.

  config.vm.box = "gusztavvargadr/ubuntu-server"
  config.vm.network "private_network", ip: "192.168.1.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "ubuntu-server"
    vb.check_guest_additions = false

    # Customize the amount of memory on the VM:
    vb.memory = "1024"
    vb.cpus = 2
    vb.gui = true
  end

  config.vm.provision "shell", path: "command.sh"

  #Copy Nginx configuration
  config.vm.synced_folder "config", "/var/www/config", create: true

  #Copy Laravel Project
  config.vm.synced_folder "project", "/var/www/project", create: true, group: "www-data", owner: "www-data"
end
```

## Create Shell Provisioning
on the root project directory, create a new .sh file, called 'command.sh'.

```shell
#!/bin/bash

#Update
sudo apt-get update

#Install dependencies and add PHP8.0 repository
sudo apt install  ca-certificates apt-transport-https software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y

# install nginx
sudo apt-get install nginx -y

# Set firewall permission
echo "y" | sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 443
sudo ufw allow 80
sudo ufw allow 22

# You should install PHP8.0 version to run the Laravel Project
sudo apt update 
sudo apt install php8.0-common php8.0-cli -y

# install PHP package
sudo apt-get install php8.0-mbstring php8.0-xml composer unzip -y
sudo apt-get install php8.0-curl php8.0-mysql php8.0-fpm -y

# install MYSQL
sudo apt-get install mysql-server -y

# Set MYSQL password
sudo apt-get install debconf-utils -y
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

# Nginx config
sudo cp /var/www/config/example.conf /etc/nginx/sites-available/example.conf

# Copy to sites-enabled directory
sudo ln -s /etc/nginx/sites-available/example.conf /etc/nginx/sites-enabled
sudo service nginx restart
```

## Create Nginx configuration
inside the root project, create a new folder called 'config'. Then create a new configuration file for Nginx inside the config folder. This folder can be synced with the VM.

```shell
server {
        listen 80;
        root /var/www/html/project/public;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name localhost;

        location / {
                try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}
```

## Upload Laravel project
Then create new folder on the root project, called 'project'. You can use Laravel Project from this repo:
```shell
git clone https://gitlab.com/kuuhaku86/web-penugasan-individu.git
```

## Running the project

```shell
vagrant up
```

Access the VM using vagrant SSH.

```shell
vagrant ssh
```

## Create new Database
Access MySQL
```shell
sudo mysql -u root -p <- default null password

CREATE DATABASE DATABASE_NAME;
CREATE USER 'USER'@'%' IDENTIFIED BY 'PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE_NAME.* TO 'USER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

## Create Application Environment

```
sudo cp .env.example .env
sudo nano /var/www/project/.env
```
### Add debug
```
APP_DEBUG=true
LOG_DEBUG=true
```
### Edit .env file
config the DB_DATABASE, DB_USERNAME, DB_PASSWORD and other.

```shell
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
```
## Composer

### Composer Install
```
sudo composer install
```

###  Composer Update(optional)

```
sudo composer update
```

### Upgrade Composer 
```
sudo run which composer (output /usr/bin/composer)
sudo run php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo run sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
```

## Artisan
```
sudo php artisan key:generate
sudo php artisan migrate
```

## Some Errors
### what appears is still the Nginx default page
Solution remove the default
```
sudo rm -rf /etc/nginx/sites-enabled/default
sudo service nginx reload
```

## Vagrant Destory
```
vagrant destroy
```
