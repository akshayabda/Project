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

#menu to setup or uninstall Prometheus
echo -e "WELCOME TO PROMETHEUS SETUP!!\n1. \e[92mInstall\e[0m\n2.\e[91m Purge\e[0m"
echo -e "\e[33mEnter Reply here:\e[0m"
read reply
case ${reply} in

1)	echo -e "\n1. Install Prometheus on Server Side\n2. Install Node Exporter on Client Side"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in

	#case one is setting up prometheus on server.
	1)	mkdir /prometheus
		cd /prometheus

		#accpeting link from where to download prometheus sourcecode
		echo -e "Give link to download Prometheus!!"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read reply
		wget ${reply}

		#checking if download was successful
		#if succesfull then extract prometheus
		if [ -e prometheus-2.2.1.linux-amd64.tar.gz ]
		then
			tar -zvxf prometheus-2.2.1.linux-amd64.tar.gz
		else
			echo -e "\e[91mWGET Failed!\e[0m"
		fi

		#check extract was successful change directory
		if [ -d prometheus-2.2.1.linux-amd64 ]
		then
			cd prometheus-2.2.1.linux-amd64
		else
			echo -e "\e[91mExtracting Failed!\e[0m"
		fi

		echo "How many clients to monitor"
		read reply
		counter=2
		while [ $counter -le $reply ]
		do
			echo "Give a job name!!"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read name
			sed  -i 23s/"prometheus'"/${name}",&"/ prometheus.yml
			echo "Give client IP!!"
			echo -e "\e[33mEnter Reply here:\e[0m"echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			sed -i 29s/localhost:9090/${ip}:9100"','&"/ prometheus.yml
			((counter++))
		done

		#we here edit prometheus configurations as per user requirement
		echo "Give a job name!!"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read name
		#editing prometheus.yml to assign job name to client server
		sed -i 23s/prometheus/${name}/ prometheus.yml
		echo "Give client IP!!"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read ip
		#editing prometheus.yml to assign client server IP
		sed -i 29s/localhost:9090/${ip}:9100/ prometheus.yml

		echo -e "Configure Client Now??\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
		read reply
		case $reply in
		1)	echo "Number of clients to configure with node exporter"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read reply
			counter=1
			while [ $counter -le $reply ]
			do
			/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ prometheusClient.sh
			((counter++))
			done
		;;
		*)	echo -e "\t\e[91mSKIPPED\e[0m"
		;;
		esac

		echo "execute nodeExporter script in its directory on client and press 'y' to continue"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read reply
		if [ $reply == 'y' ]; then
			echo "Starting Prometheus..."
			cd /prometheus/prometheus-2.2.1.linux-amd64/
			./prometheus &
		else
			echo "execute nodeExporter script in its directory on client first"
		fi
	;;

	#case two is to configure NodeExporter on client machine
	2)	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ prometheusClient.sh
		cd /prometheus/prometheus-2.2.1.linux-amd64/
		echo "Starting Prometheues..."
		./prometheus &
	;;
	esac
;;

#case condition to uninstall prometheus
2)	echo -e "Purge who?\n1. Prometheus on Server\n2. Node Exporter on Client"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read reply
	case ${reply} in
	#uninstall on server
	1)	cd
		rm -rf /prometheus
		echo -e "\e[91mPurged Prometheus on Server\e[0m"
	;;

	#uninstall nodeExporter on client
	2)	echo "Client IP?"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read ip
		echo "Password?"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read pw
		sshpass -p ${pw} ssh -o "StrictHostKeyChecking no" ${ip} -T bash -c "'
		rm -rf /nodeExporter
		'"
		echo -e "\e[91mPurged Node Exporter on Client\e[0m"
	;;
	esac
;;
esac

#exiting script
exit
