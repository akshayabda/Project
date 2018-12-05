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

echo -e "Install Or Purge DNS??\n1. \e[92mInstall\e[0m\n2. \e[91mSkip\e[0m 3. \e[91Purge\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case $reply in

1)	apt-get update
	apt-get install bind9 dnsutils --force-yes -y

	echo -e "\nUpdate resolv.conf"
	echo -e "To make the change\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
	read reply
	case $reply in
	1)	echo -e "On this machine or Client??\n1. This machine\n2. Client"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read reply
		case $reply in
		1)	echo -e "\e[92mGive IP of DNS server\e[0m"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			chattr -i /etc/resolv.conf
			sed -i s/localdomain/`hostname -d`/g /etc/resolv.conf
			echo "nameserver ${ip}" >> /etc/resolv.conf
			chattr +i /etc/resolv.conf
		;;

		2)	echo "How many clients?"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read A
			echo "Give DNS server IP??"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			echo "Give DNS server Domain Name"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read nm
			counter=1
			while [ $counter -le $A ]
			do
				echo "Give client IP"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read host
				ssh -o "StrictHostKeyChecking no" -T $host bash -c "'
				chattr -i /etc/resolv.conf
				sed -i s/localdomain/$nm/g /etc/resolv.conf
				sed -i -e '3s/[0-9].*.[0-9]/$ip/' /etc/resolv.conf
				chattr +i /etc/resolv.conf
				'"
				((counter++))
			done
		;;
		esac
	;;

	2)	echo -e "\t\e[91mLeaving\e[0m"
	;;
	esac

	echo -e "Add Forward Zone entry in file \n1. \e[92mYes\e[0m\n2. \e[91mDone Already\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case $reply in
	1)	v=`hostname -d`
		if [ -e /etc/bind/named.conf.local ]; then
			echo -e "\nzone \"${v}\"{\n\ttype master;\n\tfile \"/etc/bind/db.${v}\";\n};\n " >> /etc/bind/named.conf.local
			cp /etc/bind/db.local /etc/bind/db.`hostname -d`
		else
			echo -e "\e[91mnamed.conf.local not found\e[0m"
		fi
	;;

	2)	echo -e "\t\e[92mLeaving zone file\e[0m"
	;;
	esac

	echo -e "Add reverse zone entry in file\n1. \e[92mYes\e[0m\n2. \e[91mDone Already!\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case $reply in
	1)	if [[ -e /etc/bind/db.127 && /etc/bind/db.local && /etc/bind/named.conf.local ]]; then
		echo "How many Reverse Lookup Needed?"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read A
		echo "$A" > /etc/bind/here.txt
		counter=1
		while [ $counter -le ${A} ]
		do
			cp /etc/bind/db.127 /etc/bind/db.192.$counter
			echo -e "zone \"N${counter}.in-addr.arpa\"{\n\ttype master;\n\tfile \"/etc/bind/db.192.${counter}\";\n};\n " >> /etc/bind/named.conf.local
			((counter++))
		done
		else
			echo -e "\t\e[91mAPT-GET Failed or CHECK named.conf file\e[0m"
		fi
	;;

	2)	echo -e "\t\e[91mLeaving\e[0m"
	;;
	esac

	echo -e "Want to Initialize DNS Forward and Reverse DB Files??\n1. \e[92mYes\e[0m \n2. Done Already!"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case $reply in
	1)	echo "Please Give NameServer(NS):"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read dns
		sed -i 5s/root.localhost./root.`hostname -d`./ /etc/bind/db.`hostname -d`
		sed -i 5s/localhost./${dns}.`hostname -d`./ /etc/bind/db.`hostname -d`
		sed -i 12s/@/''/ /etc/bind/db.`hostname -d`
		sed -i 13s/@/";"/ /etc/bind/db.`hostname -d`
		sed -i 14s/@/";"/ /etc/bind/db.`hostname -d`
		sed -i 12s/localhost./${dns}.`hostname -d`./ /etc/bind/db.`hostname -d`
		echo "Give IP for NameServer's A entry"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read ip
		echo -e "$dns\tIN\tA\t$ip" >> /etc/bind/db.`hostname -d`

		A=$(cat /etc/bind/here.txt)
		counter=1
		while [ $counter -le ${A} ]
		do
			sed -i 5s/root.localhost./root.`hostname -d`./ /etc/bind/db.192.$counter
			sed -i 5s/localhost./${dns}.`hostname -d`./ /etc/bind/db.192.$counter
			sed -i 12s/localhost./${dns}.`hostname -d`./ /etc/bind/db.192.$counter
			sed -i 13s/localhost./`hostname -d`./ /etc/bind/db.192.$counter
			((counter++))
		done
	;;

	2)	echo -e "\t\e[91mLeaving!\e[0m"
	;;
	esac

	echo "Do You want to Make Entries to Forward DB??"
	echo -e "1. \e[92mYes\e[0m\n2. \e[91mSkip\e[0m"
	read reply
	case $reply in
	1)	echo "How many number of (A) entires??"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read A
		counter=1
		while [ $counter -le ${A} ]
		do
			echo "Give short name:"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read s
			echo "Give IP to resolve ${s}:"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			echo -e "${s}\tIN\tA\t$ip" >> /etc/bind/db.`hostname -d`
			((counter++))
		done

		echo "Any CNAME entry??"
		echo -e "1. \e[92mYes\e[0m 2. \e[91mNO!\e[0m"
		read reply
		case $reply in
		1)	echo "How many number of (CNAME) entires??"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read A
			counter=1
			while [ $counter -le ${A} ]
			do
				echo "Give short name:"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read s
				echo "Give Short name to resolve ${s}:"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read ip
				echo -e "${s}\tIN\tCNAME\t$ip" >> /etc/bind/db.`hostname -d`
				((counter++))
			done
		;;

		2)	echo -e "\e[36mNO CNAME ENTRY!\e[0m"
		;;
		esac
	;;

	2)	echo "Ignored Forward DB!!"
	;;
	esac

	echo -e "\nWant to add entires to Reverse Database!!\n1. \e[92mYes\e[0m\n2. \e[91mNo!\e[0m"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case $reply in
	1)	A=$(cat /etc/bind/here.txt)
		counter=1
		while [ $counter -le ${A} ]
		do
			echo -e "enter network for which you want add entries?\nFormat N3.N2.N1 i.e. netowrk part only in reverse!!"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read n
			echo -e "db.192.$counter: Is For $n!!\n" >> /etc/bind/reverse.txt
			sed -i s/N${counter}/"$n"/ /etc/bind/named.conf.local
			echo "How many number of PTR entires for network $n??"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read B
			count=1
			while [ ${count} -le ${B} ]
			do
				echo "Give Last Octate:"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read s
				echo "Give FQDN to resolve ${s}:"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read fqdn
				echo -e "${s}\tIN\tPTR\t$fqdn." >> /etc/bind/db.192.$counter
				((count++))
				echo -e "DNS Server and CNAME entry to resolve??\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
				echo -e "\e[33mEnter Reply here:\e[0m"
				read reply
				case ${reply} in
				1)	echo "How many entries??"
					echo -e "\e[33mEnter Reply here:\e[0m"
					read C
					counter=1
					while [ ${counter} -le ${C} ]
					do
						echo "Give Last Octate:"
						echo -e "\e[33mEnter Reply here:\e[0m"
						read s
						echo "Give FQDN ro resolve ${s}:"
						echo -e "\e[33mEnter Reply here:\e[0m"
						read fqdn
						echo -e "${s}\tIN\tPTR\t$fqdn." >> /etc/bind/db.192.$counter
					((counter++))
					done
				;;
				2)	echo -e "\e[91mLeaving\e[0m"
				;;
				esac
			done
			((counter++))
		done
	;;

	2)	echo "Exiting Reverse DB!"
	;;
	esac

	service bind9 restart
	service bind9 status
;;

3)	echo "Purge Initiated!!"
	rm -rf /etc/bind/*
	rm -rf /var/cache/bind/
	apt-get purge dnsutils bind9 --force-yes -y
	apt-get autoremove --force-yes -y
;;

*)	echo -e "\e[91mSKIPPED\e[0m"
;;
esac
#exiting code
exit

