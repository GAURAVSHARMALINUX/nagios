#!/usr/bin/env bash

## This script install the NRPE daemon on Centos Based Machine.
# Checking Server is Centos 7 Based or not, If yes then script will run continue otherwise it will be terminated.
echo "Suppose to be run this script on Centos7/RHEL7 based operation system."
OS=`/usr/bin/hostnamectl status  | grep -i "Operating System:" | awk -F: {'print $2'} | awk {'print $1 "" $2 "" $3'}`
clear
if [[ $OS -eq "CentOSLinux7" ]];then
echo -e "This System is Centos 7 Based so installtion is progress\nThanks and Support us.\nGaurav Sharma\n+91-8233233753,gauravsharmasit@gmail.com\n"
else
echo -e "This system not full fill the requirment to install nagios on this\nThis script support only Centos 7 based image\nThanks and Support us.\nGaurav Sharma\n+91-8233233753,gauravsharmasit@gmail.com\n"
exit 0
fi

# Predefine files and variable.
LOG_FILE='/var/log/nrpe-installation.log'
HN=`cat /etc/hostname`
IP=`nmcli -p device show | grep -i IP4.ADDRESS | head -n1 | awk {'print $2'} | awk -F/ {'print $1'}`

#Installing Epel-release and updating the server.
echo -e "Updating server"
rpm -ih https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm >> $LOG_FILE 2>&1
yum makecache >> $LOG_FILE 2>&1
yum update -y >> $LOG_FILE 2>&1
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils gcc glibc glibc-common openssl openssl-devel perl wget >> $LOG_FILE 2>&1
yum --enablerepo=powertools,epel install perl-Net-SNMP -y >> $LOG_FILE 2>&1

#Downloading and compiling source code.
cd /tmp
wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.0.3.tar.gz
tar xzf nrpe.tar.gz
cd /tmp/nrpe-nrpe-4.0.3/
./configure --enable-command-args
make all
make install-groups-users
make install
make install-config
make install-init
systemctl enable nrpe.service
systemctl start nrpe.service