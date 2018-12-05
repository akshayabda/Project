#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0 ];then
	echo "Please login as ROOT user."
exit
fi

#Menu for OpenVPN
echo -e "Wellcome To OpenVPN without SSL\n1. Install OpenVPN\n2. Purge OpenVPN"
read reply
case $reply in

#cases to install or uninstall openVPN
1)	echo -e "OpenVPN without SSL\n1. Server\n2. Client"
	read reply
	case $reply in

	#case to setup openvpn on server
	1)
	echo "Server Side Setup"
	apt-get install tree tcpdump openvpn --force-yes -y
	if [ -d /etc/openvpn ]; then
		cd /etc/openvpn/
		touch ser.conf
		echo "Give Server VPN IP"
		read sip
		echo "Give Client VPN IP"
		read cip
		echo -e "proto udp\nport 1194\ndev tun\nauth none\ncipher none\nifconfig $sip $cip\nverb 3" > ser.conf
	else
		echo "APT-GET FAILED!!"
	fi
	echo "Now do the same on Client PC starting VPN now"
	openvpn --config /etc/openvpn/ser.conf
	;;

	#case to setup openvpn on client
	2)	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ vpnClient.sh
	;;
	esac
;;

#Uninstalltion Case
2)	echo -e "Purge Setup\n1. Purge Server OpenVPN\n2. Purge Client OpenVPN"
	read reply
	case $reply in

	#case to uninstall openvpn on server
	1)	apt-get purge openvpn --force-yes -y
		apt-get autoremove --force-yes -y
	;;

	#case to uninstall openvpn on client
	2)	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ vpnClient.sh
	;;
	esac
;;
esac

