Version EasyLEMP for Centos-7-64x
============

What is EasyLEMP ?
===================
EasyLEMP is some bash script. EasyLEMP will help you install LEMP( Nginx, PHP-FPM, MariaDB on Linux ) and some other software like CSF, Composer...
You only need to copy below code to terminal, then press enter. Wait about 3 minutes. Restart VPS. Enter command "easylemp" to access menu.
You can create user, domain for each user. And the last, EasyLEMP was written to optimus speed and security with multi pool PHP.

How to install
============

yum -y install git && cd /tmp/ && git clone https://github.com/Laraviorg/EasyLEMP.git && sh /tmp/EasyLEMP/install.sh

You also can install Dev Version
============

yum -y install git && cd /tmp/ && git clone --branch dev https://github.com/Laraviorg/EasyLEMP.git && sh /tmp/EasyLEMP/install.sh

How to use
==========
After install successfully, please restart VPS.
Then you can use command "easylemp" to access main menu.
Press 1,2 or 3... to do action in menu.
