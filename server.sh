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

echo -e "Need to Setup repository, hostname, IP?\n1. \e[92mYes\e[0m\n2. \e[91mNo\e[0m"
read reply
case ${reply} in
1)      /etc/VAH/scripts/repo.sh
        /etc/VAH/scripts/hostname.sh
        /etc/VAH/scripts/network.sh
        /etc/VAH/scripts/resolv.sh
;;

*)      echo "You Have Skipped Baic Configurations!!"
;;
esac

