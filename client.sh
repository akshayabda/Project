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

echo -e "Client Intial Settings\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
read reply
case $reply in
1)      echo "How many clients to configure??"
	echo -e "\e[33mEnter Reply here:\e[0m"
        read reply
        counter=1
        while [ $counter -le $reply ]
        do
                /etc/VAH/scripts/scp.sh /etc/VAH/scripts/ repo.sh hostname.sh network.sh resolv.sh
                ((counter++))
        done
;;

*)      echo -e "\e[91mSKIPPED\e[0m"
;;
esac

