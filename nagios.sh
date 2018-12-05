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

echo -e "Welcome to Nagios Setup\n1. \e[92mInstall\e[0m\n2. \e[91mPurge\e[0m"
read reply
case $reply in
1)	apt-get update
	apt-get install tree unzip curl apache2 apache2-utils xinetd libgd2-xpm-dev libapache2-mod-php5 mariadb-client mariadb-server php5 php5-mcrypt php5-common php5-curl php5-mysqlnd php5-gd php5-cgi openssl libssl1.0.0 libssl-dev build-essential dos2unix --force-yes -y
	useradd nagios
	echo -e "\e[36mGive Password For Nagios User\e[0m"
	passwd nagios
	groupadd nagcmd
	usermod -a -G nagcmd nagios
	usermod -G nagcmd www-data

	mkdir /nagios
	cd /nagios
	echo "Give link For Nagios..."
	echo -e "\e[33mEnter Reply here:\e[0m"
	read nagios
	wget ${nagios}
	echo "Give Link For Nagios Plugins..."
	echo -e "\e[33mEnter Reply here:\e[0m"
	read plugin
	wget ${plugin}
	echo "Give Link For NRPE..."
	echo -e "\e[33mEnter Reply here:\e[0m"
	read nrpe
	wget ${nrpe}
	echo "Give Link for debian.txt"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read link
	wget ${link}

	if [[ -e /nagios/nagios-4.3.2.tar.gz && -e /nagios/nagios-plugins-2.2.1.tar.gz && -e /nagios/nrpe-3.1.0.tar.gz ]]
	then
		tar -zvxf nagios-4.3.2.tar.gz
		tar -zvxf nagios-plugins-2.2.1.tar.gz
		tar -zvxf nrpe-3.1.0.tar.gz
	else
		echo -e "\t\e[91mNagios related one or more setup was not successfully downloaded!\e[0m"
	fi

	cd nagios-4.3.2
	./configure --with-nagios-group=nagios --with-command-group=nagcmd
	make all
	make install
	make install-init
	make install-commandmode
	make install-config
	make install-webconf

	cd /nagios/nagios-plugins-2.2.1
	./configure --with-nagios-user=nagios --with-nagios-group=nagcmd --with-openssl
	make
	make install

	cd /nagios/nrpe-3.1.0
	./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl=/usr/lib/x86_64-linux-gnu
	make all
	make install-daemon
	make install-plugin

	cp sample-config/nrpe.cfg /usr/local/nagios/etc/nrpe.cfg
	ip=$(ifconfig eth0 | grep 'inet\s' | awk '{print $2}' | cut -d: -f2)
	sed -i s/allowed_hosts=127.0.0.1,/"&${ip},"/1 /usr/local/nagios/etc/nrpe.cfg
	/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d

	/usr/local/nagios/libexec/check_nrpe -H $ip

	echo -e "define command{\n\tcommand_name\tcheck_nrpe\n\tcommand_line\t\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -c \$ARG1\$\n\t}" >> /usr/local/nagios/etc/objects/commands.cfg
	sed -i 's/cfg_dir=\/usr\/local\/nagios\/etc\/servers/Put Your Debian Clients To Monitor in below Directory Path\n&/' /usr/local/nagios/etc/nagios.cfg
	sed -i 's/cfg_file=\/usr\/local\/nagios\/etc\/objects\/windows.cfg/Edit Client Details in this Configuration File below\n&/' /usr/local/nagios/etc/nagios.cfg
	mkdir /usr/local/nagios/etc/servers

	a2enmod rewrite
	a2enmod cgi

	echo -e "\e[36mGive Password For NagoisAdmin\e[0m"
	htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

	cp /nagios/debian.txt /usr/local/nagios/etc/servers/debian.cfg
	sed -i 15,21d /usr/local/nagios/etc/servers/debian.cfg

	echo "Any debian clients to monitor?? Give Number of clients to monitor"
	echo -e "\e[33mEnter Reply here:\e[0m"
	read value
	if [ $value == 0 ]
	then
		echo -e "\e[36mNo clients To monitor\e[0m"
	else
		counter=2
		count=1
		while [ $counter -le $value ]
		do
			echo "Give alias name for client number ${count}"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read name
			echo "Give IP for client ${name}"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			sed -i 15s/^/"\ndefine host{\n\tuse\tlinux-box-remote\t; Inherit default values from a template\n\thost_name\t${name}\t; The name we're giving to this server\n\talias\t${name}\t; A longer name for the server\n\taddress\t${ip}\t; IP address of the server\n\t}\n"/ /usr/local/nagios/etc/servers/debian.cfg
			sed -i s/FC19/${name}",&"/g /usr/local/nagios/etc/servers/debian.cfg
			((counter++))
			((count++))
		done
		echo "Give alias name for client number $count"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read name
		echo "Give IP for client $name"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read ip
		sed -i 15s/^/"\ndefine host{\n\tuse\tlinux-box-remote\t; Inherit default values from a template\n\thost_name\t${name}\t; The name we're giving to this server\n\talias\t${name}\t; A longer name for the server\n\taddress\t${ip}\t; IP address of the server\n\t}\n"/  /usr/local/nagios/etc/servers/debian.cfg
		sed -i s/FC19/$name/g /usr/local/nagios/etc/servers/debian.cfg
	fi

	echo "Any Windows Client to monitor?? Number of clients to monitor"
	read value
	if [ $value == 0 ]
	then
		echo -e "\e[36mNo clients to monitor\e[0m"
	else
		counter=2
		count=1
		while [ $counter -le $value ]
		do
			echo "Give alias name for client number $count"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read name
			echo "Give IP for client $name"
			echo -e "\e[33mEnter Reply here:\e[0m"
			read ip
			sed -i 30s/^/"\ndefine host{\n\tuse\t\twindows-server\t; Inherit default values from a template\n\thost_name\t${name}\t; The name we're giving to this host\n\talias\t\tMy Windows Server\t; A longer name associated with the host\n\taddress\t\t$ip\t; IP address of the host\n\t}\n"/  /usr/local/nagios/etc/objects/windows.cfg
			sed -i  s/winserver/${name}",&"/g /usr/local/nagios/etc/objects/windows.cfg
			((count++))
			((counter++))
		done

		echo "Give alias name for client number $count"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read name
		echo "Give IP for client $name"
		echo -e "\e[33mEnter Reply here:\e[0m"
		read ip
		sed -i 30s/^/"\ndefine host{\n\tuse\t\twindows-server\t; Inherit default values from a template\n\thost_name\t${name}\t; The name we're giving to this host\n\talias\t\tMy Windows Server\t; A longer name associated with the host\n\taddress\t\t$ip\t; IP address of the host\n\t}\n"/  /usr/local/nagios/etc/objects/windows.cfg
		sed -i s/winserver/${name}/g  /usr/local/nagios/etc/obejcts/windows.cfg
	fi

	warn=$(/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg | grep "Total Warnings" | awk '{print $3}')
	err=$(/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg | grep "Total Errors" | awk '{print $3}')

	if [[ $warn == 0 && $err == 0 ]]
	then
		echo -e "\e[92mNo Errors!\e[0m"
		service apache2 reload
		service apache2 restart
		service nagios start
		servic nagios status
		echo -e "\e[36mIf still Error Strongly recommended to reboot and restart nagios service\e[0m\n1. \e[92mReboot\e[0m\n2. \e[92mWorking No Need!!\e[0m"
		read reply
		case $reply in
			1)	reboot
			;;
			2)	echo -e "\e[92mInstalled Nagios\e[0m"
			;;
		esac
	else
		echo -e "\e[91mErrors!!\e[0m"
		/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
	fi
	;;

2)	service nagios stop
	userdel nagios
	groupdel nagcmd
	rm -rf /usr/local/nagios /nagios
	apt-get purge mariadb-client mariadb-server php5 php5-mcrypt php5-curl php5-common php5-cgi php5-gd php5-mysqlnd tree build-essential libssl-dev curl libgd2-xpm-dev apache2 apache2-utils libapache2-mod-php5 xinetd unzip --force-yes -y
	apt-get autoremove --force-yes -y;;
esac
