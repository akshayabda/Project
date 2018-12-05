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

#Prompt to user to Select if he wants to set repository paths
echo -e "\nDo You Want to setup repository??\n1.\e[92m Yes\e[0m\n2.\e[91m No\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case ${reply} in

#Here the link is set according to the Protocol of link (http/https/ftp/ftps viz)
#this is according to local repository.
1)	echo -e "Protocol??\nexample: ftp/http"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read protocol
	echo -e "Give the Server IP for Repository!!\n\e[92mFormat: x.x.x.x i.e. dotted decimal\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read ip

	#If we have direct link to repository then provision for the same
	#echo -e "Give path for repo!!"
	#read reply
	#echo "$reply" > /etc/apt/sources.list

	#using echo to override sources.list file and then appending further lines as per requirement
	echo "deb ${protocol}://${ip}/sw/repo/debian/ jessie main" > /etc/apt/sources.list
	echo "deb ${protocol}://${ip}/sw/repo/maria_db/debian/8.6.0/amd64/ /" >> /etc/apt/sources.list
	apt-get update
	apt-get install sshpass
;;

*)	echo -e "\t\e[91mExiting\e[0m\n";;
esac

#exiting script after this
exit
