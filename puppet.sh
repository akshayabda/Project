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

echo -e "Welcome To Puppet Setup!!\n1. Install Puppet\n2. Purge Puppet"
read reply
case $reply in
1)	echo -e "Want to do Basic Configurations??\n1. Yes\n2. No"
	read reply
	case $reply in
	1)	/etc/VAH/scripts/repo.sh
		echo "Puppet needs Hostname customised!!"
		/etc/VAH/scripts/hostname.sh
		echo -e "Puppet needs Static IP:\n"`hostname -I`
		/etc/VAH/scripts/network.sh
		echo "Puppet needs DNS settings to!!"
		/etc/VAH/scripts/dns.sh
	;;
	esac

	echo -e "Setup Puppet on\n1. Server\n2. Client\n3. Only sign Certificates"
	read reply
	case $reply in

	1)	echo "Bypass Firewall For ntpdate: Enter done to continue"
		read y
		echo "Asia/Kolkata" > /etc/timezone
		apt-get update
		apt-get install ntpdate tree tcpdump --force-yes -y
		ntpdate pool.ntp.org
		apt-get install ntp --force-yes -y
		service ntp restart
		apt-get install puppetmaster-passenger --force-yes -y
		service apache2 stop
		echo -e "Package: puppet puppet-common puppetmaster-passenger\nPin: version 3.7.*\nPin Priority: 501" > /etc/apt/preferences.d/00-puppet.pref
		touch /etc/puppet/manifests/site.pp
		rm -rf /var/lib/puppet/ssl
		if [ -e /etc/puppet/puppet.conf ]; then
			cp /etc/puppet/puppet.conf /etc/puppet/puppet.conf.back
		else
			echo "APT-GET FAILED"
		fi
		sed -i -e '9s/^/certname=puppet/' /etc/puppet/puppet.conf
		sed -i -e 10s/^/dns_alt_names=`hostname -s`,`hostname -f`'\n\n'/ /etc/puppet/puppet.conf
		echo "Once use see Puppet Master with Version number contorl+c to contiune further..."
		puppet master --verbose --no-daemonize

		sed -i 23s/`hostname -f`.pem/puppet.pem/ /etc/apache2/sites-enabled/puppetmaster.conf
		sed -i 24s/`hostname -f`.pem/puppet.pem/ /etc/apache2/sites-enabled/puppetmaster.conf
		service apache2 start

		#Indicate to Write Manisfest File
		echo "Create tasks in manifests!!"


		echo -e "Want to configure puppet agent on client machine now??\n Enter 'YES'...\n"
		read reply
		if [ $reply == 'YES' ];then
			echo "How many Client do you want to configure"
			read value
			counter=1
			while [ $counter -le $value ]
			do
				/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ puppetClient.sh
				echo "Done with $counter number of client configurations\n Number client you said to configure $value"
				((counter++))
			done
		else
			echo "Exiting script"
			exit
		fi

		puppet cert list

		echo "How many Certificates to sign??"
		read a
		while [ $a -le $counter ]
		do
			echo "Give name of Certificate to sign"
			read reply
			puppet cert sign ${reply}
			((counter++))
		done
		puppet cert list -all
	;;

	#Case two to setup puppet on client machine
	2)	echo "How many Client do you want to configure"
		read value
		counter=1
		while [ $counter -le $value ]
		do
			/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ puppetClient.sh
			echo "Done with $counter number of client configurations\n Number client you said to configure $value"
			((counter++))
		done
	;;

	#case three to only sign puppet agents
	3)	puppet cert list
		echo "How many Certificates to sign??"
		read a
		counter=1
		while [ $counter -le $a ]
		do
			echo "Give name of Certificate to sign"
			read reply
			puppet cert sign ${reply}
			((counter++))
		done
		puppet cert list -all
	;;
	esac
;;

2)	echo -e "Purge Puppet\n1. Server\n2. Client"
	read reply
	case $reply in
	1)	rm -rf /etc/puppet/*
		rm -rf /var/log/puppet/*
		serive bind9 stop
		apt-get purge bind9 dnsutils  puppet puppet-common puppetmaster-passenger --force-yes -y
		apt-get autoremove --force-yes -y
	;;
	2)	echo "On how many clients you want to Purge Puppet?"
		read value
		while [ $counter -le $value ]
		do
			/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ puppetClient.sh
			echo "Done with $counter number of client\n Number client you said to purge $value"
			((counter++))
		done
	;;
	esac
;;
esac
#exiting script
exit
