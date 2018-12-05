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

echo -e "Need to Configure Hostname??\n1. \e[92mYes\e[0m\n2.\e[91m No\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
#Optional Case if hostname is already set.
read reply
case ${reply} in

#switch case 1 to setup hostname
#we edit /etc/hosts and /etc/hostname to set hostname
#init 6 which is also optional to user but recommended to restart for clean code practice
1)	echo -e "\nPlease Provide a Hostname:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read host
	echo "${host}" > /etc/hostname
	sed -i 2s/debian/"${host}"/g /etc/hosts
	echo -e "Strongly adviced to reboot!! \n1. \e[92mReboot\e[0m \n2. \e[92mContinue\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in
	1)	init 6
	;;
	2)	echo -e "\e[91mNot rebooting\e[0m"
	;;
	esac
;;

#2nd case if hostname needs no change exit message to user
*)	echo -e "\t\e[91mExiting\e[0m"
;;
esac

#exiting script
exit
