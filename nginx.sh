#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo "Please login as ROOT user."
exit
fi

echo -e "Welcome To Nginx\n1. Install Nginx Server\n2. Purge"
read reply
case $reply in

#case to setup nginx on exposed server
1)	apt-get install nginx tcpdump tree --force-yes -y
	rm /etc/nginx/sites-enabled/*
	#Give IP of The server you want to send request to !!
	echo "Give Server IP!!"
	read ip
	echo -e "server{\n\tlisten 80;\n\tlocation / {\n\t\tproxy_pass http://${ip};\n\t}\n}\n" > /etc/nginx/sites-available/rp.conf

	ln -s /etc/nginx/sites-available/rp.conf /etc/nginx/sites-enabled/

	service nginx start
	service nginx status
;;

#caseto uninstall nginx
2)	service nginx stop
	apt-get purge nginx  nginx-common --force-yes -y
	apt-get autoremove --force-yes -y
	rm -rf
;;
esac
#exiting script
exit
