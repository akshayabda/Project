#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo -e "\[91mPlease login as ROOT user.\e[0m"
	exit
fi

#first we check before editing interfaces file if backup taken f original or not!
#if taken we proceed if not we take one time backup and then proceed.
#backup is important to reset the setting if user makes any mistake while setting up.
if [ -e /etc/network/interfaces.backup ];then
 echo "\e[92mBackUP Taken Already\e[0m"
else
 echo "\e[92mBackup not taken\e[0m"
 cp /etc/network/interfaces /etc/network/interfaces.backup
 echo "\e[92Fresh Backup Taken now\e[0m"
fi

echo -e "Need to setup or reset networking??\n1. Setup\n2. Reset\n3. \e[91mSkip\e[0m"
read reply
case $reply in
1)	sed -i '11,12s/^/#/g' /etc/network/interfaces
	echo -e "\nNumber of Network Adapters to set static IP?"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	count=0
	counter=1
	while [ $counter -le $reply ]
	do
	echo -e "Setting ETH$count Static!!"
	echo "Setup For Static IP"
	echo "Provide IP:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read ip
	echo "Provide SubNetMask:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read sm
	echo "Provide Network:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read nt
	echo "Provide Broadcast:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read bc
	echo "Provide Gateway:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read gt
	echo "Provide DNS IP:"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read dns

	echo -e "\nallow-auto eth$count\niface eth$count inet static\n" >> /etc/network/interfaces
	echo -e "\taddress\t${ip}\n\tnetmask\t${sm}\n\tnetwork\t${nt}\n\tbroadcast\t${bc}\n\tgateway\t${gt}\n\tdns-nameserver\t${dns}\n" >> /etc/network/interfaces
	((counter++))
	((count++))
	done
	service networking restart
;;

2)	cp /etc/network/interfaces.backup /etc/network/interfaces
	rm -rf /etc/network/interfaces.backup
;;

*)	echo -e "\t\e[91mSKIPPED\e[0m"
;;
esac

#exiting script after this
exit
