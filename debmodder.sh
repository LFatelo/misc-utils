#!/bin/bash

##FUTURE NOTE: Add custom configuration options and service start options

function menu() {
    clear
    while true
    do	
	printf "*** THIS TOOL WAS MADE BASED ON DEBIAN 10 ***"
	printf "Welcome to the Debian system assistant\n"
	printf "Please select an option\n"
	printf "1) Install basic tools\n"
	printf "2) Install graphical session\n"
	printf "3) Grant administration priveleges to a user\n"
	printf "4) Install HTTP server\n"
	printf "5) Install FTP server\n"
	printf "q) Exit\n"
	read OPTION

	case $OPTION in
	    1)
		basicinstall
		;;
	    2)
		guiinstall
		;;
	    3)
		authorize
		;;
	    4)
		httpinstall
		;;
	    5)
		ftpinstall
		;;
	    q)
		exit 0
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		menu
		;;
	    esac
    done
}

function basicinstall() {
    apt update
    apt -y install vim sudo emacs htop openssh-server openssh-client curl tmux
}

function authorize() {
    clear
    while true
    do
	printf "Please specify the user you wish to to authorize\n"
	read user
	checkuser=`getent passwd $user | wc -l`
	if [ "$checkuser" == "0" ]
	then
	    printf "User does not exist. Please specify an existing user\n"
	    authorize
	else
	    usermod $user -a -G sudo
	    read -n 1 -s -r -p "User sucessfully authorized. Press any key to continue."
	    menu
	fi
    done
}

function sechard() {
    clear 
    while true
    do	
	printf "*** SECURITY HARDENING ***\n"
	printf "Select an option\n"
	printf "1) Install and enable firewall\n"
	printf "2) Remove insecure services (if they exist)\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		fireinst
		;;
	    2)
		insec
		;;
	    0)
		menu
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key and try again\n"
		sechard
		;;
	esac   
}

function fireinst() {
    clear
    while true
    do
	printf "*** FIREWALL OPTIONS ***\n" # TODO: Add options for iptables
	printf "Select a firewall frontend\n"
	printf "1) ufw\n"
	printf "2) firewalld\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		ufwinstaller
		;;
	    2)
		firewalldinst
		;;
	    0)
		sechard
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key and try again\n"
		fireinst
		;;
	esac	
    done
}

function insec() {
    clear
    while true
    do
	printf "*** INSECURE SERVICE REMOVAL ***\n"
	printf "Please select an option\n"
	printf "1) Remove Telnet services\n"
	printf "2) Remove Rsh services\n"
	printf "3) Remove TFTP services\n"
	printf "4) All of the above\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		apt purge -y telnetd
		read -n 1 -s -r -p "Telnet service removed. Press any key to continue\n"
		;;
	    2)
		apt purge -y rsh-server rsh-redone-server 
		read -n 1 -s -r -p "Rsh services removed. Press any key to continue\n"
		;;
	    3)
		apt purge -y tftpd atftpd tftpd-hpa
		read -n 1 -s -r -p "TFTP services removed. Press any key to continue\n"
		;;
	    4)
		apt purge -y telnetd rsh-server rsh-redone-server tftpd atftpd tftpd-hpa
		read -n 1 -s -r -p "Services removed. Press any key to continue\n"
		;;
	    0)
		sechard
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key and try again\n"		
		;;
	esac
}

function ufwinstaller() {
    clear
    printf "*** INSTALLING UFW ***\n"
    apt -y update
    apt -y install ufw
    ufw default deny incoming
    ufw default allow outgoing
    printf "Do you wish to enable ports/services now?[Y/N]\n"
    read servans
    servans=`echo ${servans,,}`

    while [ "$servans" == "y" ]
    do 
	printf "Please indicate the port/service you wish to enable.\n" # To add in the future: options for selecting TCP or UDP and indicating services instead of ports, also options for port ranges
	read portans
	
	ufw allow $portans
	
	printf "Do you wish to enable more ports/services?[Y/N]\n"
	read moreans
	servans=`echo ${servans,,}`
    done
    ufw enable
    
}

function firewalldinst() {
    clear
    printf "*** INSTALLING FIREWALLD ***\n"
    apt -y update
    apt -y install firewalld
    systemctl enable firewalld
    printf "Do you wish to enable ports/services now?[Y/N]\n"
    read servans
    servans=`echo ${servans,,}`

    while [ "$servans" == "y" ]
    do
	printf "Please indicate the port you wish to enable.\n" # To add in the future: options for selecting TCP or UDP and indicating services instead of ports, also options for port ranges
	read portans
	   
	firewall-cmd --add-port=$portans/tcp --permanent

	printf "Do you wish to enable another port?[Y/N]\n"
	read servans
	servans=`echo ${servans,,}`
    done
    
    firewall-cmd --reload
    systemctl restart firewalld
    systemctl status firewalld
}

function guiinstall() {
    clear
    while true
    do
	printf "Select an option\n"
	printf "1) Window Managers\n"
	printf "2) Desktop Environments\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		wminstall
		;;
	    2)
		deinstall
		;;
	    0)
		menu
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		guiinstall
		;;
	esac
    done
}

function wminstall() {
    clear
    while true
    do
	printf "Select an option\n"
	printf "1) IceWM\n"
	printf "2) FVWM\n"
	printf "3) xmonad\n"
	printf "4) Blackbox\n"
	printf "5) Fluxbox\n"
	printf "6) Openbox\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		apt -y install xorg icewm
		;;
	    2)
		apt -y install xorg fvwm
		;;
	    3)
		apt -y install xorg xmonad
		;;
	    4)
		apt -y install xorg blackbox
		;;
	    5)
		apt -y install xorg fluxbox
		;;
	    6)
		apt -y install xorg openbox menu
		;;
	    0)
		guiinstall
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		wminstall
		;;
	esac
    done
}

function deinstall() {
    clear
    while true
    do
	printf "Select an option\n"
	printf "1) GNOME\n"
	printf "2) MATE\n"
	printf "3) XFCE\n"
	printf "4) LXDE\n"
	printf "5) KDE Plasma\n"
	printf "6) LXQt\n"
	printf "7) GNUstep\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		apt -y install task-gnome-desktop
		;;
	    2)
		apt -y install xorg mate-desktop-environment mate-tweak 
		;;
	    3)
		apt -y install xfce4
		;;
	    4)
		apt -y install xorg lxde
		;;
	    5)
		apt -y install task-kde-desktop
		;;
	    6)
		apt -y install lxqt
		;;
	    7)
		apt -y install x-window-system-core wmaker menu
		apt -y install gnustep
		;;
	    0)
		guiinstall
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		deinstall
		;;
	esac
    done
}

function httpinstall() {
    clear
    while true
    do
	printf "Select your preferred HTTP server\n"
	printf "1) Apache HTTP Server\n"
	printf "2) NGINX HTTP Server\n"
	printf "3) lighttpd HTTP Server\n"
	printf "0) Return to previous menu\n"
	read OPTION

	case $OPTION in
	    1)
		apt -y install apache2
		while true
		do
		    printf "Would you like to enable Apache server on boot?[Y/N]\n"
		    read apaopt
		    apaopt=`echo ${apaopt,,}`
		    if [ "$apaopt" == "y" ]
		    then
			systemctl enable apache2
			systemctl start apache2
			systemctl status apache2
			read -n 1 -s -r -p "Installation successful. Server is now enabled on boot. Press any key to return to the previous menu"
			httpinstall
		    elif ["$apaopt" == "n" ]
			read -n 1 -s -r -p "Installation succesful. Press any key to return to the previous menu"
			httpinstall
		    else
			printf "Invalid option\n"
		    fi
		done
		;;
	    2)
		apt -y install nginx-full
		;;
	    3)
		apt -y install lighttpd
		;;
	    0)
		menu
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		httpinstall
		;;
	esac
    done   
}

function ftpinstall() {
    clear
    while true
    do
	printf "Select your preferred FTP server\n"
	printf "1) VSFTP FTP Server\n"
	printf "2) PureFTP FTP Server\n"
	printf "0) Return to previous menu\n"
	read OPTION
	case $OPTION in
	    1)
		apt -y install vsftpd
		systemctl enable vsftpd
		systemctl start vsftpd
		;;
	    2)
		apt -y install pure-ftpd
		systemctl enable pure-ftpd
		systemctl start pure-ftpd
		# future note, add options to also install server with LDAP, MySQL or PostgreSQL authentication
		;;
	    0)
		menu
		;;
	    *)
		read -n 1 -s -r -p "Invalid option. Press any key to return to menu."
		ftpinstall
		;;
	esac
    done
}

menu
