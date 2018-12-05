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

echo -e "Edit resolv.conf file for dns only\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
read reply
case $reply in
1)	echo "Give domain name"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read name
	echo "Give DNS IP"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read ip
	chattr -i /etc/resolv.conf
	sed -i s/localdomain/$name/g /etc/resolv.onf
	sed -i 's/[0-9].*.[0-9]/'$ip'/' /etc.resolv.conf
	chattr +i /etc/resolv.conf
;;

*)	echo -e "\t\e[91mSKIPPED\e[0m\n"
;;
esac
