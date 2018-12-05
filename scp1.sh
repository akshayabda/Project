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

#information gathering for scp and taking shell of client machine to run script
echo "Give Client IP"
echo -e "\e[33mEnter Reply here:\e[0m"
read ip

echo "Give Client User Name"
echo -e "\e[33mEnter Reply here:\e[0m"
read nm

echo "Give Clinet password"
echo -e "\e[33mEnter Reply here:\e[0m"
read pw

path=$1
sh=$2

echo "Give Target Directory"
echo -e "\e[33mEnter Reply here:\e[0m"
read dir

#creating target directory
sshpass -p $pw ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'mkdir $dir
apt-get update
apt-get install sshpass --force-yes
'"

echo -e "1. \e[92mRun Script\e[0m\n2. \e[91mDelete Script\e[0m"
read reply
case ${reply} in

1)	if [ -e $path$sh ]
	then
	sshpass -p $pw scp -o "StrictHostKeyChecking no" $path$sh ${nm}@$ip:$dir
	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'
	cd $dir
	./$sh
	cd /
	rm -rf $dir
	'"
	else
		echo -e "\e[91mFile Not Found!!\e[0m"
	fi;;

2)	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'
	rm -rf $dir
	echo "\e[92mDone!\e[0m"
	'";;
esac
