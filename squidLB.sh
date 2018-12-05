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

echo -e "Install Squid\n1. Yes Install\n2. Purge Squid"
read reply
case $reply in
1)	apt-get update
	apt-get install squid3 --force-yes -y
	echo -e "Give name for access control list\neg. my_acl"
	read acl
	sed -i 's/acl CONNECT method CONNECT/&\nacl '$acl' dstdomain '`hostname -f`'/' /etc/squid3/squid.conf
	sed -i 's/# And finally deny all other access to this proxy/http_access allow '$acl'\n&/' /etc/squid3/squid.conf
	sed -i 's/http_port 3128/&\nhttp_port 80 vhost/'  /etc/squid3/squid.conf
	echo "Give short name of 1st server"
	read name
	echo "Give ${name} server IP"
	read ip
	sed -i 's/#  TAG: cache_peer_domain/cache_peer '$ip' parent 80 0 no_query originserver round-robin weight=1 name='$name'\n&/'  /etc/squid3/squid.conf
	echo "Give short name of 2nd server"
	read name
	echo "Give ${name} server IP"
	read ip
	sed -i 's/#  TAG: cache_peer_domain/cache_peer '$ip' parent 80 0 no_query originserver round-robin weight=1 name='$name'\n&/'  /etc/squid3/squid.conf
	sed -i 's/#  TAG: unique_hostname/visible_hostname '`hostname -f`'\n&/'  /etc/squid3/squid.conf

;;
2)	apt-get update
	apt-get purge squid3 --force-yes -y
;;
esac
