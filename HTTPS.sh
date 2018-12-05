#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo -e "\e[91mPlease login as ROOT user.\e[0m"
exit
fi

echo -e " 1. \e[92mHTTPS Setup\e[0m\n 2. \e[91mHTTPS PURGE\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case $reply in

1)	apt-get update
	apt-get install openssl apache2 --force-yes -y
	if [ -d /etc/apache2 ]
	then
		a2enmod ssl
		service apache2 restart
		a2ensite default-ssl
		service apache2 reload
		mkdir /etc/apache2/ssl
	else
		echo -e "\e[91mAPT Failed!\e[0m"
	fi

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
	chmod 600 /etc/apache2/ssl

	echo "Give Mail ID"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read em
	echo "Give Server IP"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read ip
	if [ -e /etc/apache2/sites-enabled/default-ssl.conf ]
	then
		sed -i s/webmaster@localhost/$em/ /etc/apache2/sites-enabled/default-ssl.conf
		sed -i s/$em/'&\n\t\tServerName '$ip':443'/ /etc/apache2/sites-enabled/default-ssl.conf
		sed -i '33s|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/apache2/ssl/apache.crt|g' /etc/apache2/sites-enabled/default-ssl.conf
		sed -i '34s|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/apache2/ssl/apache.key|g' /etc/apache2/sites-enabled/default-ssl.conf
	else
		echo -e "\t\e[91mdefault-ssl.conf not available!\e[0m"
	fi

	service apache2 restart
	openssl s_client -connect $ip:443
	echo -e "\e[36mNow Go Visit Site $ip on chrome.\e[0m"
;;

2)	apt-get update
	apt-get purge openssl apache2 --force-yes -y
	apt-get autoremove --force-yes -y
	rm -rf /etc/apache2;;

esac

