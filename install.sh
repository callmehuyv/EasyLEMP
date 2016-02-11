#!/bin/bash
#MOVE TO ETC/EASYLEMP
mkdir /etc/easylemp/
mv /tmp/EasyLEMP/* /etc/easylemp/
mv /etc/easylemp/sources/MariaDB.repo /etc/yum.repos.d/
mv /etc/easylemp/sources/Nginx.repo /etc/yum.repos.d/
cd /etc/easylemp/

#CLEAN BEFORE INSTALL

yum -y update
clear
yum clean all

#Install some package
yum install sed which -y

# GET INFO CPU
number_cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )

#DISABLE selinux
rm -rf /etc/selinux/config
mv /etc/easylemp/sources/config /etc/selinux/
#NOT TEST /etc/sysconfig/selinux

#STOP, REMOVE, REMOVE SOMETHING
systemctl stop sendmail.service
systemctl disable sendmail.service
systemctl stop xinetd.service
systemctl disable xinetd.service
systemctl stop saslauthd.service
systemctl disable saslauthd.service
systemctl stop rsyslog.service
systemctl disable rsyslog.service
systemctl stop postfix.service
systemctl disable postfix.service
systemctl stop httpd*.service
systemctl disable httpd*.service
systemctl stop php*.service
systemctl disable php*.service
systemctl stop mysql*.service
systemctl disable mysql*.service

yum -y remove mysql*
yum -y remove php*
yum -y remove httpd*
yum -y remove sendmail*
yum -y remove postfix*
yum -y remove rsyslog*

#IPTABLE
yum -y install iptables-services
systemctl start iptables.service
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save

#INSTALL NGINX
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

yum --enablerepo=remi,remi-php56 install -y nginx php-fpm php-common
systemctl enable nginx.service

mkdir /etc/nginx/users
mv /etc/easylemp/sources/staticfiles.conf /etc/nginx/conf.d/
mv /etc/easylemp/sources/block.conf /etc/nginx/conf.d/
rm -rf /etc/nginx/nginx.conf
mv /etc/easylemp/sources/nginx.conf /etc/nginx/
sed -i "s/number_cores/$number_cores/g" /etc/nginx/nginx.conf

#INSTALL PHP-FPM
yum --enablerepo=remi,remi-php56 install -y php-devel php-opcache php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongo php-pecl-sqlite php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
rm -rf /etc/php-fpm.d/www.conf
rm -rf /etc/php-fpm.conf
mv /etc/easylemp/sources/php-fpm.conf /etc/
rm -rf /etc/php.ini
mv /etc/easylemp/sources/php.ini /etc/

mkdir /etc/php-fpm.d/users/
mkdir /etc/php-fpm.d/socks/
chown -R nginx:nginx /etc/php-fpm.d/socks/

systemctl enable php-fpm.service

#INSTALL MARIADB
yum remove MariaDB* -y
yum -y install MariaDB-server MariaDB-client
systemctl start mariadb
mysql_secure_installation
cp -fr /etc/easylemp/sources/my.cnf /etc/
systemctl enable mariadb.service

#INSTALL MEMECACHED
yum -y install memcached
systemctl start memcached
systemctl enable memcached

#MOVE MENU, SOURCE
mv /etc/easylemp/sources/easylemp /usr/sbin
chmod +x /usr/sbin/easylemp
chmod 600 /etc/easylemp/sources/*.sh
chmod 700 -R /etc/easylemp/

#INSTALL CFS FIREWALL
yum -y install wget perl unzip net-tools perl-libwww-perl perl-LWP-Protocol-https perl-GDGraph -y
wget http://www.configserver.com/free/csf.tgz
tar -xzf csf.tgz
ufw disable
cd csf
sh install.sh

sed -i 's/AUTO_UPDATES = "1"/AUTO_UPDATES = "0"/g' /etc/csf/csf.conf
sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_DSHIELD = "0"/LF_DSHIELD = "86400"/g' /etc/csf/csf.conf
sed -i 's/LF_SPAMHAUS = "0"/LF_SPAMHAUS = "86400"/g' /etc/csf/csf.conf
sed -i 's/LF_EXPLOIT = "300"/LF_EXPLOIT = "86400"/g' /etc/csf/csf.conf
sed -i 's/LF_DIRWATCH = "300"/LF_DIRWATCH = "86400"/g' /etc/csf/csf.conf
sed -i 's/LF_INTEGRITY = "3600"/LF_INTEGRITY = "0"/g' /etc/csf/csf.conf
sed -i 's/LF_PARSE = "5"/LF_PARSE = "20"/g' /etc/csf/csf.conf
sed -i 's/LF_PARSE = "600"/LF_PARSE = "20"/g' /etc/csf/csf.conf
sed -i 's/PS_LIMIT = "10"/PS_LIMIT = "15"/g' /etc/csf/csf.conf
sed -i 's/PT_LIMIT = "60"/PT_LIMIT = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERPROC = "10"/PT_USERPROC = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERMEM = "200"/PT_USERMEM = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_USERTIME = "1800"/PT_USERTIME = "0"/g' /etc/csf/csf.conf
sed -i 's/PT_LOAD = "30"/PT_LOAD = "600"/g' /etc/csf/csf.conf
sed -i 's/PT_LOAD_AVG = "5"/PT_LOAD_AVG = "15"/g' /etc/csf/csf.conf
sed -i 's/PT_LOAD_LEVEL = "6"/PT_LOAD_LEVEL = "8"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTATTACK = "0"/LF_DISTATTACK = "1"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTFTP = "0"/LF_DISTFTP = "1"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTFTP_UNIQ = "3"/LF_DISTFTP_UNIQ = "6"/g' /etc/csf/csf.conf
sed -i 's/LF_DISTFTP_PERM = "3600"/LF_DISTFTP_PERM = "6000"/g' /etc/csf/csf.conf
sed -i 's/DENY_IP_LIMIT = \"100\"/DENY_IP_LIMIT = \"200\"/' /etc/csf/csf.conf
sed -i 's/DENY_TEMP_IP_LIMIT = \"100\"/DENY_TEMP_IP_LIMIT = \"200\"/' /etc/csf/csf.conf

csf -r
service iptables restart

#INSTALL OTHER COMPOMENT
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

yum -y install net-tools unzip zip

#SET TIME
timedatectl set-timezone Asia/Ho_Chi_Minh

#RESTART VPS!!!!!!!!!!!!!
#/sbin/shutdown -r now
