#!/bin/sh
PORTS=/usr/ports
SUDODIR=/usr/local/bin/sudo

# check for updates
freebsd-update fetch install

# check for ports tree and download it if not existent
if [ -d $PORTS ]
then
	break
else
	portsnap fetch extract
fi

# install package manager from ports
cd /usr/ports/ports-mgmt/pkg
make install clean

# installation of miscellaneous tools
pkg install -y vim htop

# check for existence of sudo package and install if not existent
if [ -d $SUDODIR ]
then
	break
else
	pkg install -y sudo
	echo "Enter a user to authorize for sudo usage"
	read sudouser
	echo "$sudouser ALL=(ALL) ALL"
fi

# install ports tree management tool
cd /usr/ports/ports-mgmt/portmaster
make install clean

# check if there are additional services to be installed
echo "Press 'y' to install Apache Web Server. Press anything else to skip."
read httpans

if [ $httpans == "y" ]
then
	portmaster www/apache24
	echo "Press 'y' to enable Apache Web Server on boot and to initialize it. Press anything else to skip."
	read httpena
	if [ $httpena == "y" ]
	then
		echo 'apache24_enable="YES"' >> /etc/rc.conf
		/usr/local/etc/rc.d/apache24 start
	else
		break
	fi
else
	break
fi

echo "Press 'y' to install vsftp FTP server. Press anything else to skip."
read ftpans

if [ $ftpans == "y" ]
then
	portmaster ftp/vsftp
	echo "Creating virtu FTP user"
	echo "virtu:1111:1111::::"FTP User":/nonexistent:nologin:" >> ~/ftpuser
	adduser -C -q -D -f ~/ftpuser
	rm -rf ~/ftpuser
	echo "Press 'y' to enable vsftp FTP server on boot and to initialize it. Press anything else to skip."
	read ftpena
	if [ $ftpena == "y" ]
	then
		echo 'vsftpd_enable="YES"' >> /etc/rc.conf
		/usr/local/etc/rc.d/vsftpd start
	else
		break
	fi
fi
