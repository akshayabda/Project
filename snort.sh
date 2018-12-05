#!/usr/bin/env bash

#making script exit when command fails
#set -o errexit

#making script exit when using undeclared variables
set -o nounset

#verify if root user logged in.
if [ $EUID -ne 0  ];then
	echo -e "\e[91mPlease login as ROOT user.\e[0m"
exit
fi

#pre-requisite sconfiguration scripts called just in -case
#/etc/VAH/scripts/repo.sh
#/etc/VAH/scripts/network.sh
#/etc/VAH/scripts/hostname.sh


echo -e "Snort\n1. \e[92mInstall\e[0m\n2. \e[91mPurge\e[0m"
read reply
case ${reply} in
1)	#add user and group for snort
	groupadd snort
	useradd snort -r -s /usr/sbin/nologin -c SNORT_IDS -g snort

	#install dependencies for snort
	apt-get update
	apt-get install tree make bison pkg-config checkinstall flex build-essential \
	iptables-dev libnet1 libnet1-dev libc6-dev libc-dev-bin \
	libdnet libdnet-dev libdumbnet1 libdumbnet-dev \
	libghc-zlib-dev libpcre3-dev linux-libc-dev libpcap-dev libnfnetlink-dev libnetfilter-queue1 libnetfilter-queue-dev --force-yes -y

	#create directory to donwload source code of snort and daq
	mkdir /snort_src
	cd /snort_src

	#downloading the source codes
	echo -e "Please Provide the download link for snort!!"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read snort
	wget ${snort}
	echo -e "Please Provide the download link for DAQ!!"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read daq
	wget ${daq}
	daq=$( ls | grep daq )
	tar -zvxf ${daq}

	#daq installation
	cd daq-2.0.6
	./configure
	make
	make install

	#snort installation
	cd /snort_src
	snort=$(ls | grep snort)
	tar -zvxf ${snort}
	cd snort-2.9.8.3
	snort=$(pwd | cut -d'/' -f3)
	./configure --enable-sourcefire
	make
	make install

	ldconfig
	snort -V

	#make these directories for snort:
	mkdir /etc/snort
	mkdir /etc/snort/rules
	mkdir /etc/snort/preproc_rules
	mkdir /var/log/snort
	mkdir /usr/local/lib/snort_dynamicrules

	cp /snort_src/${snort}/etc/*.conf* /etc/snort
	cp /snort_src/${snort}/etc/*.map /etc/snort

	cp /etc/snort/snort.conf /etc/snort/snort.conf.backup


	cd /etc/snort/rules
	touch white_list.rules black_list.rules local.rules
	cd /snort_src

	chmod -R 5775 /etc/snort
	chmod -R 5775 /var/log/snort/
	chmod -R 5775 /usr/local/lib/snort/
	chmod -R 5775 /usr/local/lib/snort_dynamicrules/
	chmod -R 5775 /usr/local/lib/snort_dynamicengine/
	chmod -R 5775 /usr/local/lib/snort_dynamicpreprocessor/
	chmod -R 5775 /usr/local/lib/pkgconfig/
	chmod -R 5775 /usr/local/bin/daq-modules-config
	chmod -R 5775 /usr/local/bin/u2boat
	chmod -R 5775 /usr/local/bin/u2spewfoo

	chown -R snort:snort /etc/snort
	chown -R snort:snort /var/log/snort/
	chown -R snort:snort /usr/local/lib/snort/
	chown -R snort:snort /usr/local/lib/snort_dynamicrules/
	chown -R snort:snort /usr/local/lib/snort_dynamicengine/
	chown -R snort:snort /usr/local/lib/snort_dynamicpreprocessor/
	chown -R snort:snort /usr/local/lib/pkgconfig/
	chown -R snort:snort /usr/local/bin/daq-modules-config
	chown -R snort:snort /usr/local/bin/u2boat
	chown -R snort:snort /usr/local/bin/u2spewfoo

	sed -i '104s|\.\.|/etc/snort|' /etc/snort/snort.conf
	sed -i '105s|\.\.|/etc/snort|' /etc/snort/snort.conf
	sed -i '106s|\.\.|/etc/snort|' /etc/snort/snort.conf
	sed -i '113s|\.\.|/etc/snort|' /etc/snort/snort.conf
	sed -i '114s|\.\.|/etc/snort|' /etc/snort/snort.conf
	sed -i 548,651d /etc/snort/snort.conf
	sed -i '547s|^|include\t\$RULE_PATH/white_list.rules\ninclude\t\$RULE_PATH/black_list.rules|' /etc/snort/snort.conf
	echo "alert icmp any any -> any any (msg:\"IP Packet\";sid:666666)" > /etc/snort/rules/local.rules

	snort -T -i eth0 -u snort -g snort -c /etc/snort/snort.conf
;;

2)	echo -e "Purge Snort!!"
	apt-get update
	apt-get purge  make tree bison pkg-config checkinstall flex build-essential \
	iptables-dev libnet1 libnet1-dev libc6-dev libc-dev-bin \
	libdnet libdnet-dev libdumbnet1 libdumbnet-dev \
	libghc-zlib-dev libpcre3-dev linux-libc-dev libpcap-dev libnfnetlink-dev libnetfilter-queue1 libnetfilter-queue-dev --force-yes -y
	apt-get autoremove --force-yes -y
	userdel snort
	rm -rf /etc/snort
	rm -rf /etc/snort/rules
	rm -rf /etc/snort/preproc_rules
	rm -rf /var/log/snort
	rm -rf /usr/local/lib/snort_dynamicrules
	rm -rf /root/snort_src/
;;
esac
echo done
#exiting code
exit
