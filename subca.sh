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

echo -e "Setup??\n1. Setup SubCA\n2. Sign CSR if any\n3. Purge SubCA"
read reply
case ${reply} in

1)	apt-get update
	apt-get install tree dos2unix --force-yes -y
	mkdir /root/subca
	cd /root/subca/
	mkdir certs newcerts private csr crl
	touch index.txt index.txt.attr
	echo 1000 > serial
	echo 1000 > crlnumber
	chmod 700 private/
	echo "Give path for subca.cnf"
	read path
	wget ${path}
	dos2unix subca.cnf
	openssl genrsa -aes256 -out private/subca.key.pem
	chmod 400 private/subca.key.pem
	openssl req -config subca.cnf -new -sha256 -key private/subca.key.pem -out csr/subca.csr.pem
;;

2)	cd /root/subca/
	tree .
	cert=$(tree . | grep files | cut -d" " -f3)
	counter=5
	while [ $cert -le $counter ]
	do
		cert=$(tree . | grep files | cut -d' ' -f3)
	done

	ls /root/subca/csr/
	echo "Give CSR name to sign with extension from listed above!"
	read csr
	echo -e "message digest to use??\neg. sha1, sha256etc..."
	read md
	echo "Validity in days\neg. 365"
	read days
	echo "Output Cetificate name??\neg. www or www.hackme.local"
	read name
	openssl ca -config subca.cnf -md $md -days ${days} -notext -extensions server_cert -in csr/${csr} -out certs/${name}.cert.pem
	chmod 444 certs/${name}.cert.pem
	ls /root/subca/certs/
	cat $cname.cert.pem > ca-chain.cert.pem
        echo "Give name of your subca certificate eg. subca or subca2"
        read sname
        cat /root/subca/certs/$sname.cert.pem >> ca-chain.cert.pem
        cat /root/subca/certs/ca.cert.pem >> ca-chain.cert.pem

;;

3)	rm -rf /root/subca/
;;
esac

#exiting code
exit
