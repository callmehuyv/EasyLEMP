#!/bin/bash
#CREATE USER

SED=`which sed`
cd /etc/easylemp/sources/
echo -n "Enter user you want to create: "
read user

if [ -d "/home/$user" ] || [ $user == 'nginx' ] || [ $user == 'apache' ] || [ $user == 'root' ] || [ $user == 'www' ]; then
	echo "User already exists! Please try again!"
	exit;
else
	chmod 701 /home/
	adduser $user
	echo -n "Enter password for user $user: "
	read -s password
	echo $password | passwd --stdin $user
	chown -R $user:$user /home/$user

	mkdir /home/$user/_logs
	touch /home/$user/_logs/nginx_access.log
	touch /home/$user/_logs/nginx_error.log
	touch /home/$user/_logs/php_error.log

	chown -R root:root /home/$user/_logs

	mkdir /home/$user/_sessions
	chown -R $user:$user /home/$user/_sessions

	mkdir /etc/nginx/users/$user
	mkdir /etc/php-fpm.d/users/$user

	chmod 701 /home/$user/

	#CREATE POOL FOR USER
	cp /etc/easylemp/sources/pool.conf /etc/php-fpm.d/users/$user/pool_$user.conf
	$SED -i "s/@@USER@@/$user/g" /etc/php-fpm.d/users/$user/pool_$user.conf
	
	touch /etc/easylemp/user.log
	echo "-User $user was created" >> /etc/easylemp/user.log

	echo "OK! User $user was added."
fi
