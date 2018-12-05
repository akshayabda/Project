#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo "\e[91mPlease login as ROOT user.\e[0m"
	exit
fi

#This is the catalogue Script.
#This provides a List to What the script offers to users.
#Here the users selects the module and subsequent Installation.
#This helps to keep the Installation part seperate to use or store seperately,

echo -e "\e[36mWelcome to DITISS"
echo -e "Script for Debian OS 8.6.0\e[0m"
echo ''

#First The Script prompts user for basic pre-requsites,
# Repository, Hostname and IP addressing.
echo -e "Need to Setup Pre-requsites like repository, hostname, networking and resolv.conf??\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
read reply
case ${reply} in
1)	/etc/VAH/scripts/repo.sh
	/etc/VAH/scripts/hostname.sh
	/etc/VAH/scripts/network.sh
	/etc/VAH/scripts/resolv.sh
;;

*)	echo -e "\t\e[91mSKIPPED\e[0m\n"
;;
esac

echo -e "Client Intial Settings\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m\n"
read reply
case $reply in
1)	echo "How many clients to configure??"
	read reply
	counter=1
	while [ $counter -le $reply ]
	do
		/etc/VAH/scripts/scp.sh /etc/VAH/scripts/ repo.sh hostname.sh network.sh resolv.sh
		((counter++))
	done
;;

*)	echo -e "\t\e[91mSKIPPED\e[0m\n"
;;
esac

# Prompt user for Modules
# Each module has various setups
# later the script for each setup is called this scrip runs till the called script does not exit
echo "Please Select:"
echo -e "1. \e[92mNeed Data Centre Management tool\e[0m"
echo -e "2. \e[92mNeed Network Defence Counter measures tool\e[0m"
echo -e "3. \e[92mNeed Public Key Infrastructure tool\e[0m"
echo -e "4. \e[92mNeed Server Hardening\e[0m"
echo -e "5. \e[91mExit\e[0m\n"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case ${reply} in
1)	echo -e "Data Centre Management\n"
	echo -e "Please Select:\n1. \e[92mPuppet\e[0m\n2. \e[92mPrometheus\e[0m\n3. \e[92mNagios\e[0m\n4. \e[92mNginx\e[0m\n5. \e[92mSquid Load Balancer\e[0m"
	echo ""
	echo -e "\e[33mEnter Reply here: \e[0m"
	read reply
	case ${reply} in
	1)/etc/VAH/scripts/puppet.sh
	;;
	2)/etc/VAH/scripts/prometheus.sh
	;;
	3)/etc/VAH/scripts/nagios.sh
	;;
	4)/etc/VAH/scripts/ngnix.sh
	;;
	5)/etc/VAH/scripts/squidLB.sh
	;;
	*)echo -e "\t\e[91mWrong Preference\e[0m\n";;
	esac;;

2) 	echo -e "Network Defence Counter Measures\n"
	echo -e "Please Select:\n1. \e[92mOpenVpn without SSL\e[0m\n2. \e[92mSnort\e[0m\n3. \e[92mNagios\e[0m\n4. \e[92mNginx\e[0m\n5. \e[92mSquid(load Balancer)\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in
	1)	/etc/VAH/scripts/vpn.sh
	;;
	2)	/etc/VAH/scripts/snort.sh
	;;
	3)	/etc/VAH/scripts/nagios.sh
	;;
	4)	/etc/VAH/scripts/nginx.sh
	;;
	5)	/etc/VAH/scripts/squidLB.sh
	;;
	*)	echo -e "\t\e[91mWrong Preference\e[0m\n"
	esac
;;

3)	echo -e "Public Key Infrastructure\n"
	echo -e "Please Select:\n1. \e[92mSecure VPN\e[0m\n2. \e[92mHTTPS Self Signed\e[0m\n3. \e[92mHTTPS Complete\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in
	1)	echo "Secure Virtual Private Network"
		/etc/VAH/scripts/secvpn.sh
	;;
	2)	echo -e "HTTPS self signed Setup\n1. \e[92mOn this System\e[0m\n2. \e[92mOn Client Server\e[0m"
		read reply
		case ${reply} in
		1)/etc/VAH/scripts/HTTPS.sh
		;;
		2)/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ HTTPS.sh
		;;
		*)echo -e "\t\e[91mWrong Preference\e[0m"
		;;
		esac
	;;
	3)	/etc/VAH/scripts/fullHTTPS.sh
	;;
	*)	echo -e "\t\e[91mWrong Preference\e[0m\n"
	;;
	esac
;;

4)	echo -e "Select from: \n1. \e[92mGrub Locking\e[0m\n2. \e[92mApache Hardening\e[0m"
	echo "\e[33mEnter Reply here:\e[0m"
	read reply
	case $reply in
	1)	/etc/VAH/scripts/grub.sh
	;;
	2)	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ hard_http.sh
	;;
	esac
;;

5)	echo -e "\t\e[91mExiting Ditiss\e[0m\n";;

*)	echo -e "\t\e[91mWrong Preference\e[0m\n";;
esac

echo -e "Project Members: AKSHAY ABDAGIRI, HARISH DEWHARE, VIVEK CHANCHAL"
echo ''
#exiting script
exit
