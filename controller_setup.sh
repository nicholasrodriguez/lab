#!/bin/bash

if [[ `id -u` != 0 ]]; then
    echo "You must run this as root"
    exit 1
fi

# Install packages

yum -y update

yum -y install git

yum -y install vim

yum -y install python3

yum -y install python3-pyvmomi

yum -y install python3-dns

yum -y install python3-netaddr

yum -y install epel-release

yum -y install ansible

yum -y install xrdp

if ! dnf list installed atom; then
    curl -SLo ~/atom.rpm https://atom.io/download/rpm
    dnf -y localinstall ~/atom.rpm
fi

# Install Ansible roles

ansible-galaxy install -r requirements.yml

# Get Lab Variables

if ! grep "LAB_USER" /etc/environment; then
    read -p 'Lab User: ' LAB_USER
    echo 'export LAB_USER='$LAB_USER >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_PW" /etc/environment; then
    read -p 'Lab Password: ' LAB_PW
    echo 'export LAB_PW='$LAB_PW >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_DOMAIN" /etc/environment; then
    read -p 'Lab Domain: ' LAB_DOMAIN
    echo 'export LAB_DOMAIN='$LAB_DOMAIN >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_SUBNET" /etc/environment; then
    read -p 'Lab Subnet: ' LAB_SUBNET
    echo 'export LAB_SUBNET='$LAB_SUBNET >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_DNS1" /etc/environment; then
    read -p 'Lab DNS1: ' LAB_DNS1
    echo 'export LAB_DNS1='$LAB_DNS1 >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_DNS2" /etc/environment; then
    read -p 'Lab DNS2: ' LAB_DNS2
    echo 'export LAB_DNS2='$LAB_DNS2 >> /etc/environment
    source /etc/environment
fi

if ! grep "LAB_REPO" /etc/environment; then
    read -p 'Lab Repo( e.g. nas.labdomain.local): ' LAB_REPO
    echo 'export LAB_REPO='$LAB_REPO >> /etc/environment
    source /etc/environment
fi

# Configure XRDP

systemctl enable xrdp --now

if ! grep "xrdp8" /etc/xrdp/xrdp.ini; then
    echo '[xrdp8]' >> /etc/xrdp/xrdp.ini
    echo 'name=Reconnect' >> /etc/xrdp/xrdp.ini
    echo 'lib=libvnc.so' >> /etc/xrdp/xrdp.ini
    echo 'username=ask' >> /etc/xrdp/xrdp.ini
    echo 'password=ask' >> /etc/xrdp/xrdp.ini
    echo 'ip=127.0.0.1' >> /etc/xrdp/xrdp.ini
    echo 'port=5901' >> /etc/xrdp/xrdp.ini
fi

if ! firewall-cmd --list-ports | grep "3389"; then
    firewall-cmd --permanent --zone=public --add-port=3389/tcp
    firewall-cmd --reload
fi

# Configure VIM

FILE=/home/$LAB_USER/.vimrc
if [ ! -f  "$FILE" ]; then
    touch "$FILE"
    chown $LAB_USER:$LAB_USER "$FILE"
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi

if ! grep "color" $FILE; then
    echo 'set shiftwidth=2' >> "$FILE"
    echo 'set expandtab' >> "$FILE"
    echo 'set tabstop=4' >> "$FILE"
    echo 'color desert' >> "$FILE"
fi
