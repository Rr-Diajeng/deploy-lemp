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
sudo apt-get update 
sudo apt-get install php8.0-common php8.0-cli

# install PHP package
sudo apt-get install php8.0-mbstring php8.0-xml unzip composer -y
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
