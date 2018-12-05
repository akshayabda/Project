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
echo "Give Client User Name!!"
echo -e "\e[33mEnter Reply here:\e[0m"
read nm
echo "Give client password"
echo -e "\e[33mEnter Reply here:\e[0m"
read pw

path=$1
sh=$2
sh1=$3
sh2=$4
sh3=$5

echo "Give Target Directory to copy scripts into. This Directory will be deleted after settings"
echo -e "\e[33mEnter Reply here:\e[0m"
read dir

#creating target directory
sshpass -p $pw ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'mkdir $dir'"

echo -e "1. \e[92mRun Script\e[0m\n2. \e[91mDelete Script\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case ${reply} in
1)	if [ -e $path$sh ]
	then
	sshpass -p $pw  scp -o "StrictHostKeyChecking no" $path$sh $path$sh1 $path$sh2 $path$sh3  ${nm}@$ip:$dir
	sshpass -p $pw  ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'
	cd $dir
	./$sh
	./$sh1
	./$sh2
	./$sh3
	cd /
	rm -rf $dir
	'"
	else
		echo "\e[91mFile Not Found!\e[0m"
	fi;;

2)	ssh -o "StrictHostKeyChecking no" $ip -T bash -c "'
	rm -rf $dir
	echo "\e[92mDone!\e[0m"
	'";;
esac
