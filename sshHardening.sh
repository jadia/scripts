#!/bin/bash
: '
Harden SSH security based on https://github.com/w4rb0y/walkthrough/blob/master/sshEssesntials.md
Author: Nitish Jadia
Date: 2019-02-05
Version: v0.1.0 beta; There maybe numerous bug. Please open a issue or a pull request for the same.
'

#Blue hightlight = \e[44m
# Cyan - \e[96m
# Clear - \e[0m
# exit code : 127 command not found

##### Colors #####
blueHigh="\e[44m"
cyan="\e[96m"
clearColor="\e[0m"
redHigh="\e[41m"
green="\e[32m"

##### Variables ######

sshConfigPath="/etc/ssh/ssh_config"
user="$(who mom likes | awk '{print $1}')"
ip="$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')"
choice="y"

##### Check if script is run as root #####
if [[ $EUID -ne 0 ]]; then
   echo -e "$cyan This script must be run as root\e[0m" 
   exit 1
fi 

#### Functions

function disable_passwd() {
    # REVIEW id_rsa_2
    if [[ -e ~/.ssh/id_rsa_2 ]]; then
        echo -e "$green Keys are already present. Skipping key generation! $clearColor"
    else
        echo -e "$cyan Generating new Keys... $clearColor"
        if ! $(ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_2 -q -N ""); then
            echo -e "$redHigh Key generation failed! $clearColor"
            exit 1
        fi
    fi
    echo ""
    echo -e "$blueHigh Run the following command: $clearColor"
    echo -e "$cyan ssh-copy-id $user@$ip $clearColor"
    echo -e "$cyan After that you will be able to login without password. $clearColor"
    echo " "
    echo -e "$cyan Press [Enter] to continue.... $clearColor"
    echo ""
    read -n 1 -s

    ## Creating backup of /etc/ssh/ssh-config file
    timestamp="+%y%m%d%H%M%S"
    cp $sshConfigPath $sshConfigPath.$(date $timestamp)

    ## TODO -i -r and add $sshConfigPath instead of ssh_config
    if ! sed -i -r '/PasswordAuthentication/ s/^#/ /; s/(PasswordAuthentication).*$/\1 no/' ssh_config; then
        echo -e "$redHigh Not able to edit ssh config file. $clearColor"
        exit 1
    else
        echo -e "$green Password authentication disabled. $clearColor"
    fi

}

function change_port () {
    echo -e "$cyan Enter new port: "
    read port
# TODO add $sshConfigPath instead of ssh_config
    if ! sed -i -r '/^#   Port/ s/^#/ /; s/(Port).*$/\1 4444/' ssh_config; then
        echo -e "$redHigh Not able to edit ssh config file. $clearColor"
        exit 1
    else
        echo -e "$green SSH port changed to $port. $clearColor"
    fi

}



#+++++++++ MAIN +++++++++

echo -e "$cyan Do you want to disable SSH using password? [Yes]$clearColor"
read choice

if [[ $choice =~ ^[Yy]$ ]]; then
    disable_passwd
fi


### CHANGING DEFAULT PORT

echo -e "$cyan Do you want to change the default port of SSH? [No] $clearColor"
read choice

if [[ $choice =~ ^[Yy]$ ]]; then
    change_port
fi

# echo -e "$cyan Do you want to disable root login? [default Yes] Y/N $clearColor"
# read choice

# if [[ $choice =~ ^[Yy]$ ]]; then
#     disable_root
# fi

# echo -e "$cyan Restrict SSH access to limited users? [default Yes] Y/N $clearColor"
# read choice

# if [[ $choice =~ ^[Yy]$ ]]; then
#     user_access
# fi
