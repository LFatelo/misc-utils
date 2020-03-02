#!/bin/sh
PORTS=/usr/ports
SUDODIR=/usr/local/bin/sudo

firewallenable() {
    # initialize firewall
    echo 'pf_enable="YES"' >> /etc/rc.conf
    echo 'pf_rules="/usr/local/etc/pf.conf"' >> /etc/rc.conf
    echo 'pflog_enable="YES"' >> /etc/rc.conf
    echo 'pflog_logfile="/var/log/pflog"' >> /etc/rc.conf
    wget -O /usr/local/etc/pf.conf https://raw.githubusercontent.com/LFatelo/misc-utils/master/pf.conf
    service pf start
}

initports() {
    portsnap fetch extract
}

chkupdate() {
    freebsd-update fetch install
}

pkginstall() {
    # install package manager from ports
    cd /usr/ports/ports-mgmt/pkg
    make install clean
}

toolinstall(){
    # installation of miscellaneous tools
    pkg install -y vim htop wget curl sudo
    # install ports tree management tool
    cd /usr/ports/ports-mgmt/portmaster
    make install clean
}

sudoinstall() {
    # check for existence of sudo package and install if not existent
    pkg install -y sudo
    printf "Enter a user to authorize for sudo usage\n"
    read sudouser
    echo "$sudouser ALL=(ALL) ALL" >> /usr/local/etc/sudoers
}

apacheinstall() {
    # check if there are additional services to be installed
    portmaster www/apache24
    printf "Would you like the server to be enabled on boot?[Y/N]\n" 
    read httpena
    httpena=`echo $httpena | tr '[:upper:]' '[:lower:]'`
    if [ $httpena == "y" ]
    then
	echo 'apache24_enable="YES"' >> /etc/rc.conf
	/usr/local/etc/rc.d/apache24 start
    else
	menu
    fi
}

ftpinstall() {
    portmaster ftp/vsftpd
    printf "Do you wish to create a FTP user?[Y/N]\n"
    read ftpans
    ftpans=`echo $ftpans | tr '[:upper:]' '[:lower:]'`
    if [ $ftpans == "y" ]
    then
	printf "Please name your FTP User\n"
	read ftpuser
	echo "$ftpuser:1111:1111::::"FTP User":/nonexistent:nologin:" >> ~/ftpuser
	adduser -C -q -D -f ~/ftpuser
	rm -rf ~/ftpuser
    else
	menu
    fi
    echo "Do you wish to enable FTP server on boot? [Y/N]"
    read ftpena
    ftpena=`echo $ftpena | tr '[:upper:]' '[:lower:]'`
    if [ $ftpena == "y" ]
    then
	echo 'vsftpd_enable="YES"' >> /etc/rc.conf
	/usr/local/etc/rc.d/vsftpd start
    else
	menu
    fi
}

menu() {
    while true
    do
	clear
	printf "Welcome to the FreeBSD server initializer\n"
	printf "Please enter your desired option\n"
	printf "0) Exit\n"
     	printf "1) Start and enable the pf firewall\n"
	printf "2) Initialize the ports tree or update it if already initialized\n"
	printf "3) Check for system updates\n"
	printf "4) Install the package manager 'pkg' from ports\n"
	printf "5) Install basic tools (vim, htop, wget and curl)\n"
	printf "6) Install and enable Apache web server from ports\n"
	printf "7) Install and enable VSFTPD FTP server from ports\n"
	printf "8) Install and enable sudo package\n"
	read OPTION

	case "$OPTION" in
	    "0")
		clear
		exit 1
		;;
	    "1")
		firewallenable
		;;
	    "2")
		initports
		;;
	    "3")
		chkupdate
		;;
	    "4")
		pkginstall
		;;
	    "5")
		toolinstall
		;;
	    "6")
		apacheinstall
		;;
	    "7")
		ftpinstall
		;;
	    "8")
		sudoinstall
		;;
	    *)
		clear
		printf "Unknown option, please try again\n"
		;;
	esac
    done
}

menu
