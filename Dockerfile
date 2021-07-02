FROM ubuntu:latest

RUN apt update --fix-missing

# FIX TIMEZONE ISSUE
RUN apt install tzdata -y

# UTILS THAT ARE NEEDED
RUN apt install vim git zip wget curl -y

# STYLE TOOLS LESS AND COMPASS
# RUN apt install npm -y && npm install -g less
# RUN apt install ruby-compass -y && gem install sass-globbing

# FIX TIMEZONE ISSUE FULL
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# APACHE2 NEEDED
RUN apt-get install apache2 -y && a2enmod rewrite ssl

# MYSQL CLIENT TO CONNECT BACK TO NETWORKED MYSQL CONTAINER
RUN apt-get install mysql-client -y

# PHP NEEDED - DEFAULT UBUNTU
RUN apt-get update -y --fix-missing
RUN apt-get install -y php
RUN apt-get install -y php-common	php-curl	php-gd	php-xml	php-mysql	php-mbstring	php-zip  php-ldap php-imagick php-soap
RUN apt-get install -y libapache2-mod-php
RUN service apache2 restart

# GET ALTERNATIVE PHP VERSIONS IF YOU DON'T WANT STANDARD
# RUN apt-get install -y software-properties-common apt-utils language-pack-en-base
# RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

# PHP 5.6
# RUN apt-get update -y --fix-missing
# RUN apt-get install -y php5.6
# RUN apt-get install -y php5.6-common	php5.6-curl	php5.6-gd	php5.6-xml	php5.6-mysql	php5.6-mbstring	php5.6-zip  php5.6-ldap php5.6-imagick
# RUN apt-get install -y libapache2-mod-php5.6
# RUN update-alternatives --set php /usr/bin/php5.6 && service apache2 restart

# PHP 7.1
# RUN apt-get update -y --fix-missing
# RUN apt-get install -y php7.1
# RUN apt-get install -y php7.1-common	php7.1-curl	php7.1-gd	php7.1-xml	php7.1-mysql	php7.1-mbstring	php7.1-zip  php7.1-ldap php7.1-imagick
# RUN apt-get install -y libapache2-mod-php7.1
# RUN update-alternatives --set php /usr/bin/php7.1 && service apache2 restart

# PHP 7.3
# RUN apt-get update -y --fix-missing
# RUN apt-get install -y php7.3
# RUN apt-get install -y php7.3-common	php7.3-curl	php7.3-gd	php7.3-xml	php7.3-mysql	php7.3-mbstring	php7.3-zip  php7.3-ldap php7.3-imagick
# RUN apt-get install -y libapache2-mod-php7.3
# RUN update-alternatives --set php /usr/bin/php7.3 && service apache2 restart

# NPM
# RUN apt-get install npm -y
# RUN npm install -g node-sass
# node-sass --output-style expanded --output /app/docroot/sites/scl/themes/custom/cwd_scl/css --source-map true


# COMPOSER INSTALL
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php && mv composer.phar /usr/local/bin/composer && php -r "unlink('composer-setup.php');"

# DRUPAL CONSOLE INSTALL
# RUN curl https://drupalconsole.com/installer -L -o drupal.phar && chmod +x drupal.phar && mv drupal.phar /usr/local/bin/drupal

# DRUSH INSTALL
RUN composer global require drush/drush:8.x-dev --prefer-source && ln -s /root/.composer/vendor/drush/drush/drush /usr/local/bin
# RUN composer global require drush/drush:9.x-dev --prefer-source && ln -s /root/.composer/vendor/drush/drush/drush /usr/local/bin

#INSTALL Drupal 9 Checker
RUN composer global require mglaman/drupal-check
RUN curl -O -L https://github.com/mglaman/drupal-check/releases/latest/download/drupal-check.phar
RUN mv drupal-check.phar /usr/local/bin/drupal-check
RUN chmod +x /usr/local/bin/drupal-check
# UPDATE AND CLEANUP
# RUN apt-get dist-upgrade -y && apt-get autoremove -y

# Create bashrc
RUN echo 'export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "'  >> /root/.bashrc
RUN echo 'export CLICOLOR=1'  >> /root/.bashrc
RUN echo 'export LSCOLORS=ExFxBxDxCxegedabagacad'  >> /root/.bashrc

# D7 or D8 drush
RUN echo "alias weblogin='drush uli --root=/var/www --uri=localhost'"  >> /root/.bashrc
RUN echo "alias webcc='drush cc all --root=/var/www'"  >> /root/.bashrc
RUN echo "alias webcr='drush cr --root=/var/www'"  >> /root/.bashrc
RUN echo "alias webupdb='drush up --root=/var/www -y'"  >> /root/.bashrc
RUN echo "alias webcex='drush cex --root=/var/www'"  >> /root/.bashrc

#D8 composer drush
RUN echo "alias webloginc='drush uli --root=/var/www/web --uri=localhost'"  >> /root/.bashrc
RUN echo "alias webcrc='drush cr --root=/var/www/web'"  >> /root/.bashrc
RUN echo "alias webupdbc='drush updb --root=/var/www/web'"  >> /root/.bashrc
RUN echo "alias webcexc='drush cex --root=/var/www/web'"  >> /root/.bashrc

#Logging
RUN echo "alias weblog='tail /var/log/apache2/error.log'"  >> /root/.bashrc

#Compile Sass
RUN echo "compilesass() {"  >> /root/.bashrc
RUN echo "node-sass --output-style expanded --output \$1 --source-map true \$2"  >> /root/.bashrc
RUN echo "}"  >> /root/.bashrc

#Sourcing
RUN /bin/bash -c "source /root/.bashrc"

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
