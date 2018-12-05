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

echo -e "Puppet Client:\n1. Setup\n2. Purge"
read reply
case ${reply} in
1)	apt-get install puppet --force-yes -y
	echo -e "Package: puppet puppet-common puppet\nPin: version 3.7.*\nPin Priority: 501" > /etc/apt/preferences.d/00-puppet.pref
	if [ -e /etc/puppet/puppet.conf ]; then
		cp /etc/puppet/puppet.conf /etc/puppet/puppet.conf.back
	else
		echo "APT-GET FAILED"
	fi
	echo "Enter The FQDN of server!!"
	read fqdn
	sed -i '10,14d' /etc/puppet/puppet.conf
	echo -e "[agent]\nserver=${fqdn}" >> /etc/puppet/puppet.conf
	service puppet restart
	echo "Wait for server to sign certificate"
	exit
	echo -e "After Server has signed the certificate do --> \n puppet agent --enable \n then to test changes do -->\n puppet agent --test"
	here=1
	while [[ ${here} -ne 0 ]]
	do
		puppet agent --enable
		here=$(echo $?)
	done
;;

2)	apt-get update
	apt-get purge puppet puppet-common --force-yes -y
	apt-get autoremove --force-yes -y
	rm -rf /etc/puppet /run/puppet /usr/share/bash-completion/completions/puppet
;;
esac

#exiting code
exit
