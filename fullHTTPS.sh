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


echo -e "Setup or Purge??\n1. Setup RootCA\n2. Purge RootCA"
read reply
case ${reply} in

1)	apt-get update
	apt-get install tree dos2unix --force-yes -y
	mkdir /root/ca
	cd /root/ca
	mkdir private certs newcerts csr crl -p subca/csr subca/certs
	touch index.txt index.txt.attr
	echo 1000 > serial
	echo 1000 > crlnumber
	chmod 700 private/
	openssl genrsa -aes256 -out private/ca.key.pem 4096
	chmod 400 private/ca.key.pem
	echo "Give path of rootca.cnf"
	read path
	wget ${path}
	dos2unix rootca.cnf

	openssl req -config rootca.cnf -key private/ca.key.pem -new -sha256 -x509 -days 7300 -extensions v3_ca -out certs/ca.cert.pem
	chmod 444 certs/ca.cert.pem

	#executing script within the script with path of script as 1st argument and script name as 2nd argument
	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ subca.sh

	tree .
	var=$(tree . | grep files | cut -d" " -f3)
	counter=7
	while [ ${var} == ${counter} ]
	do
		var=$(tree . | grep files | cut -d' ' -f3)
	done

	echo "you have recieved a certificate to sign"
	ls /root/ca/subca/csr
	echo "Give name of CSR to sign"
	read csr
	echo "Give Properties to sign ${csr} "
	echo -e "message digest to use??\n eg sha1, sha256 etc..."
	read md
	echo "Validity in days? eg. 365 "
	read days
	echo "Output Cetificate name?? eg. subca or subca1"
	read name
	openssl ca -config rootca.cnf -md ${md} -extensions v3_intermediate_ca -notext -days ${days} -in subca/csr/${csr} -out subca/certs/${name}.cert.pem
	chmod 444 subca/certs/${name}.cert.pem
	echo "Give SubCA IP"
	read ip
	scp -o "StrictHostKeyChecking no" certs/ca.cert.pem  /subca/certs/${name}.cert.pem root@${ip}:/root/subca/certs/
	/etc/VAH/scripts/scp1.sh /etc/VAH/scripts/ subca.sh
;;

2)	rm -rf /root/ca
;;
esac

#exiting code
exit
