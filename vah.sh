#!/usr/bin/env bash

if [ $EUID -ne 0  ];then
        echo -e "\e[91mPlease login as ROOT user.\e[0m"
        exit
fi

mkdir -p /etc/VAH/scripts
cp scripts/* /etc/VAH/scripts/
echo "alias ditiss='/etc/VAH/scripts/ditiss.sh'" >> $HOME/.bashrc
echo "alias ditiss-server='/etc/VAH/scripts/server.sh'" >> $HOME/.bashrc
echo "alias ditiss-client='/etc/VAH/scripts/client.sh'" >> $HOME/.bashrc
source /root/.bashrc
