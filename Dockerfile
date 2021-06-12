# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lsoghomo <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/11 17:16:17 by lsoghomo          #+#    #+#              #
#    Updated: 2021/03/11 17:29:44 by lsoghomo         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# INstall OS
FROM debian:buster

# Metabase
LABEL lsoghomo="oof"

# Install updates
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install wget \
                        nginx \
                        mariadb-server \
                        php7.3 \
                        php-mysql \
                        php-fpm \
                        php-pdo \
                        php-gd \
                        php-cli \
                        php-mbstring \
                        php-zip \
                        php-xmlrpc \
                        php-xml \
                        php-soap \
                        php-intl 

# Working dir
WORKDIR /etc/nginx/sites-available/

# Copying cfg nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available/nginx.conf
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled

# Install wordpress
WORKDIR /var/www/server
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzvf latest.tar.gz
RUN rm -rf latest.tar.gz
RUN chown -R www-data:www-data /var/www/server/wordpress
WORKDIR /var/www/server/wordpress
COPY ./srcs/wp-config.php .

# Installing php-myadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz
RUN tar -xzvf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN rm -rf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN mv phpMyAdmin-5.0.4-all-languages/ /var/www/server/phpmyadmin
COPY ./srcs/config.inc.php /var/www/server/phpmyadmin

# Install ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt  -subj "/C=RU/ST=Kazan/L=Kazan/O=21/OU=21School/CN=localhost"

# copy init.sh
COPY ./srcs/init.sh ./

# opening ports (not necesarry)
EXPOSE 80 443

# launching shell at the start of Container
CMD bash ./init.sh
