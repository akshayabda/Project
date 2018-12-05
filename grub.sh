#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#Here First we check if root user is handling the script
#if condition to check effective UID is 0 if not then prompt to login as root
if [ $EUID -ne 0 ]
then
        echo -e "\e[91mPlease Login as ROOT USER!\e[0m"
        exit
fi

echo -e "Select OS Flavour\n1. Red Hat\n2. Debian"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case ${reply} in
1)	echo -e "RHEL version??\n1. Version 6.x\n2. Version 7.x and above\nTry: rpm -q centos-release"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in
	1)	echo "Give passowrd to set"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read reply
		sed -i 's/hiddenmenu/&\npassword '${reply}'/' /boot/grub/grub.conf
		echo "Reboot to check settings."
	;;
	2)	echo -e "Give superuser name"
		read reply
		echo -e "Password for grub!!"
		read pass
		echo "set superusers=${reply}" >> /etc/grub.d/40_custom
		echo "password ${reply} ${pass}" >> /etc/grub.d/40_custom
		grub2-mkconfig -o /boot/grub2/grub.cfg
	;;
	esac
;;
2)	echo -e "Grub Version\n1. Version 1\n2. Version 2"
	read repy
	case $reply in
	1)	echo "Give passowrd to set..."
		read reply
		sed -i 's/# general configuration:/&\npassword '${reply}'/' /boot/grub/menu.lst
		echo "Reboot to check settings."
	;;
	2)	echo "Give  superuser username:"
		read name
		echo -e "Give Password to set"
		read pass
		echo "set superusers=${name}" >> /etc/grub.d/40_custom
		echo "password ${name} ${pass}" >> /etc/grub.d/40_custom
		grub-mkconfig -o /boot/grub/grub.cfg
	;;
	*)echo "skipped";;
	esac
;;
*)echo "skipped";;
esac
exit




