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

echo -e "OpenVPN on Client\n1. Install OpenVPN\n2. Purge OpenVPN"
read reply
case $reply in
#case to install openVPN on client machine
1)	apt-get update
	apt-get install tree tcpdump openvpn --force-yes -y
	if [ -d /etc/openvpn ]; then
		touch /etc/openvpn/clt.conf
		echo "Give Server physical IP"
		read ip
		echo "Give Server VPN IP"
		read sip
		echo "Give Client VPN IP"
		read cip
		if [ -e /etc/openvpn/clt.conf ];then
			echo -e "remote $ip\nproto udp\nport 1194\ndev tun\nauth none\ncipher none\nifconfig $cip $sip\nverb 3" > /etc/openvpn/clt.conf
		else
			echo "No CLT Conf File"
		fi
	else
		echo "APT-GET FAILED!!"
	fi
;;

#case to uninstall openVPN on client machine
2)	apt-get update
	apt-get purge openvpn --force-yes -y
	apt-get autoremove --force-yes -y
	echo "Purged Successfull!!"
;;
esac
