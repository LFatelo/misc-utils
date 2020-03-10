#!/bin/bash
FIREWALLDSTAT=`firewall-cmd --state`

function apachequest() {
    TRIGGER=0
    yum -y update
    yum -y install httpd policycoreutils-python-utils
    if [ $FIREWALLDSTAT == "not running" ]
    then
	systemctl enable firewalld
	systemctl start firewalld
    fi
    while [ $TRIGGER == 0 ]
    do	
	printf "Do you wish to use custom network ports?[Y/N]\n"
	read portopt
	portopt=$(echo ${portopt,,})
	if [ $portopt == "y" ]
	then
	    printf "Enter what port you wish to use:\n"
	    read ports
	    firewall-cmd --zone=public --permanent --add-port=$ports/tcp
	    firewall-cmd --reload
	    semanage port -a -t http_port_t -p tcp $ports
	    sed -i "s/Listen 80/Listen $ports/g" /etc/httpd/conf/httpd.conf
	    systemctl enable httpd
	    systemctl stop httpd
	    systemctl start httpd
	    systemctl status httpd 
	    cat ~/.stat.txt
	    rm -rf ~/.stat.txt
	    TRIGGER=1
	    break
	elif [ $portopt == "n" ]
	then
	    firewall-cmd --zone=public --permanent --add-service={http,https}
	    firewall-cmd --reload
	    systemctl enable httpd
	    systemctl start httpd
	    systemctl status httpd
	    TRIGGER=1
	    break
	else
	    printf "Invalid option. Please try again\n"
	fi
    done
    menu
}

function nginxquest() {
    TRIGGER=0
    yum -y update
    yum -y install nginx
    if [ $FIREWALLDSTAT == "not running" ]
    then
	systemctl enable firewalld
	systemctl start firewalld
    fi
    while [ $TRIGGER == 0 ]
    do
	printf "Do you wish to use custom network ports?[Y/N]\n"
	read portopt
	portopt=$(echo ${portopt,,})
	if [ $portopt == "y" ]
	then
	    printf "Enter what port you wish to use:\n"
	    read ports
	    firewall-cmd --zone=public --permanent --add-port=$ports/tcp
	    firewall-cmd --reload
    	    semanage port -a -t http_port_t -p tcp $ports
	    sed -i "s/80 default_server;/$ports default_server;/g" /etc/nginx/nginx.conf
	    sed -i "s/[::]:80 default_server;/[::]:$ports default_server;/g" /etc/nginx/nginx.conf
	    systemctl enable nginx
	    systemctl start nginx
	    systemctl status nginx
	    TRIGGER=1
	    break
	elif [ $portopt == "n" ]
	then
	    firewall-cmd --zone=public --permanent --add-service={http,https}
	    firewall-cmd --reload
	    systemctl enable nginx
	    systemctl start nginx
	    systemctl status nginx
	    TRIGGER=1
	    break
	else
	    printf "Invalid option. Please try again\n"
	fi
    done
    menu
}

function vsftpdquest() {
    TRIGGER=0
    yum -y update
    yum -y install vsftpd
    if [ $FIREWALLDSTAT == "not running" ]
    then
	systemctl enable firewalld
	systemctl start firewalld
    fi
    while [ $TRIGGER == 0 ]
    do
	printf "Do you wish to use custom network ports?[Y/N]\n"
	read portopt
	portopt=$(echo ${portopt,,})
	if [ $portopt == "y" ]
	then
	    printf "Enter what port you wish to use: "
	    read ports
	    firewall-cmd --zone=public --permanent --add-port=$ports/tcp
	    semanage port -a -t ftp_port_t -p $ports
	    printf "Please indicate a custom data port range [start-end]\n"
	    read custport
	    firewall-cmd --zone=public --permanent --add-port=$custport/tcp  
	    semanage port -a -t ftp_data_port_t -p $custport
	    firewall-cmd --reload
	    sed -i "s/connect_from_port_20=YES/connect_from_port_20=NO/g" /etc/vsftpd/vsftpd.conf
	    printf "listen_port=$ports" >> /etc/vsftpd/vsftpd.conf
	    printf "ftp_data_port=$custport" >> /etc/vsftpd/vsftpd.conf
	    systemctl enable vsftpd
	    systemctl start vsftpd
	    systemctl status vsftpd
	    TRIGGER=1
	    break
	elif [ $portopt == "n" ]
	then
	    firewall-cmd --zone=public --permanent --add-service=ftp
	    firewall-cmd --reload
	    systemctl enable vsftpd
	    systemctl start vsftpd
	    systemctl status vsftpd
	    TRIGGER=1
	    break
	else
	    printf "Invalid option. Please try again\n"
	fi
    done
    menu
}

function firewallman() {
    clear
    printf "*** FIREWALL MANAGER ***\n"
    printf "Select your option\n"
    printf "1) Enable port\n"
    printf "2) Enable service\n"
    printf "3) Disable port\n"
    printf "4) Disable service\n"
    printf "0) Return to main menu\n"
    read FOPTION
    case $FOPTION in
	1)
	    enable=1
	    while [ $enable == 1 ]
	    do	
		printf "Please indicate the port you wish to enable\n"
		read portena
		
		printf "Do you wish to enable this port for TCP or UDP?[TCP, UDP or BOTH]\n"
		read typeans
		typeans=`echo ${typeans,,}`
	    
		if [ "$typeans" == "tcp" ]
		then
		    firewall-cmd --zone=public --add-port=$portena/tcp --permanent
		elif [ "$typeans" == "udp" ]
		then
	            firewall-cmd --zone=public --add-port=$portena/udp --permanent
		elif [ "$typeans" == "both" ]
		then
		    firewall-cmd --zone=public --add-port=$portena/{tcp,udp} --permanent
		else
		    printf "Invalid option, please repeat"
		fi

		printf "Do you wish to enable more ports?[Y/N]\n"
		read moreans
		moreans=`echo ${moreans,,}`

		if [ "$moreans" == "n" ]
		then
		    firewall-cmd --reload
		    enable=0
		fi
	    done
	    firewallman
	    ;;
	2)   
	    enable=1
	    while [ $enable == 1 ]
	    do
		printf "Please indicate the service you wish to enable\n"
		read servena

		firewall-cmd --zone=public --add-service=$servena --permanent

		printf "Do you wish to enable more services?[Y/N]\n"
		read moreans
		moreans=`echo ${moreans,,}`

		if [ "$moreans" == "n" ]
		then
		    firewall-cmd --reload
		    enable=0
		fi
	    done
	    firewallman
	    ;;
	3)
	    disable=1
	    while [ $disable == 1 ]
	    do
		printf "Please indicate which port you wish to disable\n"
		read portdis

		firewall-cmd --zone=public --remove-port=$portdis/{tcp,udp} --permanent

		printf "Do you wish to disable more ports?[Y/N]\n"
		read moredis
		moredis=`echo ${moredis,,}`

		if [ "$moredis" == "n" ]
		then
		    firewall-cmd --reload
		    disable=0
		fi
	    done
	    firewallman
	    ;;
	4)
	    disable=1
	    while [ $disable == 1 ]
	    do
		printf "Please indicate which service you wish to disable\n"
		read servdis

		firewall-cmd --zone=public --remove-service=$servdis --permanent

		printf "Do you wish to disable more services?[Y/N]\n"
		read moredis
		moredis=`echo ${moredis,,}`

		if [ "$moredis" == "n" ]
		then
		    firewall-cmd --reload
		    disable=0
		fi
	    done
	    firewallman
	    ;;
	0)
	    menu
	    ;;
	*)
	    printf "Invalid option, please try again\n"
	    firewallman
	    ;;
    esac
}

function menu() {
    clear
    printf "*** THIS TOOL IS BASED ON RHEL/CentOS 8 ***\n"
    printf "Welcome to the RHEL/CentOS Administrator's simple toolbox\n"
    printf "Please enter your desired option\n"
    printf "1) Install and enable Apache Web Server\n"
    printf "2) Install and enable NGINX Web Server\n"
    printf "3) Install and enable VSFTPD FTP Server\n"
    printf "4) Manage firewall\n"
    printf "q) Exit\n"
    read OPTION

    case "$OPTION" in
	"1")
	    apachequest
	    ;;
	"2")
	    nginxquest
	    ;;
	"3")
	    vsftpdquest
	    ;;
	"4")
	    firewallman
	    ;;
	"q")
	    exit 1
	    ;;
	*)
	    printf "Unknown Option, please try again\n"
	    menu
	    ;;
    esac
}

menu
