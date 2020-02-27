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
	    printf "Enter what port you wish to use:\n"
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
}

while true
do    
    printf "Welcome to the Administrator's simple toolbox\n"
    printf "Please enter your desired option\n"
    printf "1) Install and enable Apache Web Server\n"
    printf "2) Install and enable NGINX Web Server\n"
    printf "3) Install and enable VSFTPD FTP Server\n"
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
	"q")
	    exit 1
	    ;;
	*)
	    printf "Unknown Option\n"
	    ;;
    esac
done
