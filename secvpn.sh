#!/usr/bin/env bash

#making script exit when command fails
set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo "Please login as ROOT user."
exit
fi

echo -e "\n 1. Install SecureVPN\n 2. Purge SecureVPN\n"
read reply
case $reply in

1)	apt-get update
	apt-get install tree tcpdump easy-rsa openvpn --force-yes -y

	if [ -d /usr/share/easy-rsa ]
	then
		mkdir /etc/easy-rsa/
		cp /usr/share/easy-rsa/* /etc/easy-rsa/
		mkdir -p /etc/easy-rsa/dh /etc/easy-rsa/keys
	else
		echo "apt-get failed!!"
	fi

	#KEY_COUNTRY,KEY_PROVINCE,KEY_CITY,KEY_ORG, KEY_EMAIL, KEY_OU,KEY_NAME
	if [ -e /etc/easy-rsa/vars ]
	then
		echo hello
		echo "Give KEY_COUNTRY"
		read cn
		sed -i s/"US"/$cn/ /etc/easy-rsa/vars

		echo "Give KEY_PROVINCE"
		read pro
		sed -i s/"CA"/$pro/ /etc/easy-rsa/vars

		echo "Give KEY_CITY"
		read ct
		sed -i s/"SanFrancisco"/$ct/ /etc/easy-rsa/vars

		echo "Give KEY_ORG"
		read org
		sed -i s/"Fort-Funston"/$org/ /etc/easy-rsa/vars

		echo "Give KEY_EMAIL"
		read em
		sed -i s/"me@myhost.mydomain"/$em/ /etc/easy-rsa/vars

		echo "Give KEY_OU"
		read ou
		sed -i s/"MyOrganizationalUnit"/$ou/ /etc/easy-rsa/vars

		echo "Give KEY_NAME\n preferred hostname of server!"
		read nm
		sed -i s/"EasyRSA"/$nm/ /etc/easy-rsa/vars

	else
		echo "/etc/easy-rsa/vars seems to be missing! check apt-get"
	fi

	cd /etc/easy-rsa/
	openssl dhparam -out /etc/easy-rsa/dh/dh2048.pem 2048
	. ./vars
	./clean-all
	./build-ca
	#you get ca-key and ca-crt

	./build-key-server $nm
	#you get <key_name>.csr, <key_name>.key and <key_name>.crt
	tree

	if [ -d /etc/openvpn ]
	then
		cp /etc/easy-rsa/keys/{ca.crt,$nm.crt,$nm.key} /etc/openvpn/
		cp dh/dh2048.pem /etc/openvpn/
	else
		echo "re-run script"
	fi

	cd /etc/easy-rsa/

	echo "Give hostname of client machine"
	read clt
	echo "Give Server IP"
	read ip
	./build-key $clt
	#you get <client>.csr, <client>.key and <client>.crt

	gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/$nm.conf
	cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/easy-rsa/keys/$clt.ovpn

	sed -i 's|;user|user|' /etc/openvpn/$nm.conf
	sed -i 's|;group|group|' /etc/openvpn/$nm.conf
	sed -i 's|ca.crt|/etc/openvpn/ca.crt|' /etc/openvpn/$nm.conf
	sed -i 's|server.crt|/etc/openvpn/'$nm'.crt|' /etc/openvpn/$nm.conf
	sed -i 's|server.key|/etc/openvpn/'$nm'.key|' /etc/openvpn/$nm.conf
	sed -i 's|dh1024.pem|/etc/openvpn/dh2048.pem|' /etc/openvpn/$nm.conf

	sed -i 's|;user|user|' /etc/easy-rsa/keys/$clt.ovpn
	sed -i 's|;group|group|' /etc/easy-rsa/keys/$clt.ovpn
	sed -i 's|ca ca.crt|;&|' /etc/easy-rsa/keys/$clt.ovpn
	sed -i 's|cert client.crt|;&|' /etc/easy-rsa/keys/$clt.ovpn
	sed -i 's|key client.key|;&|' /etc/easy-rsa/keys/$clt.ovpn
	sed -i 's|my-server-1|'${ip}'|' /etc/easy-rsa/keys/$clt.ovpn

	echo '<ca>'  >> /etc/easy-rsa/keys/$clt.ovpn
	cat /etc/openvpn/ca.crt >> /etc/easy-rsa/keys/$clt.ovpn
	echo '</ca>'  >> /etc/easy-rsa/keys/$clt.ovpn

	echo '<cert>'  >> /etc/easy-rsa/keys/$clt.ovpn
	cat /etc/easy-rsa/keys/$clt.crt >> /etc/easy-rsa/keys/$clt.ovpn
	echo '</cert>'  >> /etc/easy-rsa/keys/$clt.ovpn

	echo '<key>'  >> /etc/easy-rsa/keys/$clt.ovpn
	cat /etc/easy-rsa/keys/$clt.key >> /etc/easy-rsa/keys/$clt.ovpn
	echo '</key>'  >> /etc/easy-rsa/keys/$clt.ovpn

	echo "Give Client IP"
	read cip
	echo "Give Client username"
	read nm
	echo "Give Client Password"
	read pw

	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $cip -T bash -c "'mkdir /root/openvpn'"
	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $cip -T bash -c "'
	apt-get update
	apt-get install openvpn --force-yes -y
	'"

	sshpass -p $pw scp -o "StrictHostKeyChecking no" /etc/easy-rsa/keys/$clt.ovpn $nm@$cip:/root/openvpn
	echo "Starting Openvpn on server Do the same on client to connect to VPN"
	openvpn --config /etc/openvpn/${nm}.conf
;;

2)	apt-get update
	apt-get purge easy-rsa openvpn --force-yes -y
	apt-get autoremove --force-yes -y
	rm -rf /etc/easy-rsa/
	echo "Purge Complete on server!!"

	echo "Give Client IP to purge on client"
	read cip
	echo "Give Client Password"
	read pw
	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $cip -T bash -c "'rm -rf /root/openvpn'"
	sshpass -p $pw ssh -o "StrictHostKeyChecking no" $cip -T bash -c "'
	apt-get update
	apt-get purge openvpn --force-yes -y
	apt-get autoremove --force-yes -y
	'"

;;
esac
