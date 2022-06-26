#!/usr/bin/env bash

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
LOG_FILE='/var/log/nagios-installation.log'
HN=`cat /etc/hostname`
IP=`nmcli -p device show | grep -i IP4.ADDRESS | head -n1 | awk {'print $2'} | awk -F/ {'print $1'}`

#Installing Epel-release and updating the server.
echo -e "Updating server"
rpm -ih https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm >> $LOG_FILE 2>&1
yum makecache >> $LOG_FILE 2>&1
yum update -y >> $LOG_FILE 2>&1

# Installing nagios core
echo -e "installing Nagios Core"
yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix wget curl >> $LOG_FILE 2>&1
cd /tmp
wget --no-check-certificate -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz >> $LOG_FILE 2>&1
tar xzf nagioscore.tar.gz >> $LOG_FILE 2>&1

# Compiling and installing nagios
cd /tmp/nagioscore-nagios-4.4.6/
./configure >> $LOG_FILE 2>&1
make all >> $LOG_FILE 2>&1

# Creating user group for nagios
make install-groups-users >> $LOG_FILE 2>&1
usermod -a -G nagios apache >> $LOG_FILE 2>&1

# Installing Nagios Binaries
make install >> $LOG_FILE 2>&1

# Install daemon
make install-daemoninit >> $LOG_FILE 2>&1
systemctl enable httpd.service >> $LOG_FILE 2>&1

# Install Command mode
make install-commandmode >> $LOG_FILE 2>&1

# Install configuration files
make install-config >> $LOG_FILE 2>&1

# Install Apache Config Files
make install-webconf >> $LOG_FILE 2>&1

# Creating Nagios user
echo "Please Enter a Password to Generate Nagios admin user."
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Starting Apache Server and nagios server
systemctl restart nagios.service httpd.service

clear
echo "####################################################################################################"
echo "Nagios successfully installed Below is your credentilas"
echo -e "Nagios URL: http://$IP/nagios \nUser Name: nagiosadmin\nPassword: Same as you entered\n\n\nNow installing plugin for nagios"

# Installing plugins
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils >> $LOG_FILE 2>&1
yum --enablerepo=powertools,epel install perl-Net-SNMP -y >> $LOG_FILE 2>&1

# Downloading and compiling plugins
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.3.3.tar.gz >> $LOG_FILE 2>&1
tar zxf nagios-plugins.tar.gz >> $LOG_FILE 2>&1
cd /tmp/nagios-plugins-release-2.3.3/
./tools/setup >> $LOG_FILE 2>&1
./configure >> $LOG_FILE 2>&1
make >> $LOG_FILE 2>&1
make install >> $LOG_FILE 2>&1
systemctl reload nagios.service