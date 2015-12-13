#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install



base=/opt/sf-apache/templates/$OSVER

if [ -d /usr/local/cpanel ]; then
	echo "skipping apache2 setup, system is controlled by cPanel"
	exit 0
elif [ ! -f $base/apache2.tpl ]; then
	echo "skipping apache2 setup, unsupported operating system version"
	exit 1
fi

bash /opt/farm/scripts/setup/role.sh php-apache

/etc/init.d/apache2 stop
update-rc.d -f apache2 remove

echo "preparing apache2 configuration"
save_original_config /etc/apache2/apache2.conf
install_customize $base/apache2.tpl /etc/apache2/apache2.conf

mkdir -p /srv/sites

if [ "$OSTYPE" = "debian" ]; then
	mkdir -p /var/log/apache2
	chown -R www-data:www-data /var/log/apache2

	if [ "$OSVER" != "debian-wheezy" ]; then
		chmod -R g+w /var/log/apache2
	fi
fi

bash /opt/farm/scripts/setup/role.sh sf-php
