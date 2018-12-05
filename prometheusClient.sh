#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo -e  "\e[91mPlease login as ROOT user.\e[0m"
exit
fi

mkdir /nodeExporter
cd /nodeExporter

#take link from user to download
echo "Give Link To download nodeExporter"
echo -e "\e[33mEnter Reply here:\e[0m"
read link

#download NodeExporter
wget ${link}

#checking if download was successful
#if successful then extract
if [ -e node_exporter-0.16.0-rc.0.linux-amd64.tar.gz ]
then
	tar -zvxf node_exporter-0.16.0-rc.0.linux-amd64.tar.gz
else
	echo -e "\e[91mWGET Failed!\e[0m"
fi

#check extracting was a success if yes then change directory
#and keep a txt to instruct steps
if [ -d node_exporter-0.16.0-rc.0.linux-amd64 ]
then
	cd node_exporter-0.16.0-rc.0.linux-amd64
else
	echo -e "\e[91mExtracting Failed!\e[0m"
fi
#exiting script
exit


