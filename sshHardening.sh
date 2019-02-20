#!/bin/bash
: '
Harden SSH security based on https://github.com/w4rb0y/walkthrough/blob/master/sshEssesntials.md
Author: Nitish Jadia
Date: 2019-02-05
Version: v1.3 ; There maybe numerous bug. Please open an issue or a pull request.
'

##### Colors #####
blueHigh="\e[44m"
cyan="\e[96m"
clearColor="\e[0m"
redHigh="\e[41m"
green="\e[32m"

##### Variables ######

sshConfigPath="/etc/ssh/sshd_config"
#sshConfigPath="ssh_config" # to test
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
    if [[ -e ~/.ssh/id_rsa ]]; then
        echo -e "$green Keys are already present. Skipping key generation! $clearColor"
    else
        echo -e "$cyan Generating new Keys... $clearColor"
        if ! $(ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""); then
            echo -e "$redHigh Key generation failed! $clearColor"
            exit 1
        fi
    fi
    echo ""
    echo -e "$blueHigh Run the following command: $clearColor"
    echo -e "$cyan ssh-copy-id $user@$ip $clearColor"
    echo -e "$cyan After that you will be able to login without password. $clearColor"
    echo " "
    echo -n -e "$cyan Press [Enter] to continue.... $clearColor"
    echo ""
    read -n 1 -s

    if ! sed -i -r '/PasswordAuthentication/ s/^#/ /; s/(PasswordAuthentication).*$/\1 no/' $sshConfigPath; then
        echo -e "$redHigh Not able to edit ssh config file. $clearColor"
        exit 1
    else
        echo -e "$green Password authentication disabled. $clearColor"
    fi

}

function change_port () {
    if ! sed -i -r '/^#   Port/ s/^#/ /; s/(Port).*$/\1 '"$port"'/' $sshConfigPath; then
        # notice how $port is kept in sed command. 
        echo -e "$redHigh Not able to edit ssh config file. $clearColor"
        exit 1
    else
        echo -e "$green SSH port changed to $port. $clearColor"
    fi

}

function disable_root () {
    echo -e "$cyan Disabling root login via SSH. $clearColor"
    # Checking if PermitRootLogin entry is present in the file or not
    if grep -q "PermitRootLogin" $sshConfigPath; then # -q = quiet
        if ! sed -i -r '/PermitRootLogin/ s/^#/ /; s/(PermitRootLogin).*$/\1 no/' $sshConfigPath; then
            echo -e "$redHigh Not able to edit ssh config file. $clearColor"
            exit 1
        else
            echo -e "$green Disable root login successful. $clearColor"
        fi
    else
        echo "PermitRootLogin no" >> $sshConfigPath
        echo -e "$green Disable root login successful 2. $clearColor"
    fi
}


#+++++++++ MAIN +++++++++

## Creating backup of /etc/ssh/ssh-config file
timestamp="+%y%m%d%H%M%S"
cp $sshConfigPath $sshConfigPath.$(date $timestamp)

# === DISABLE PASSWORD ===

echo -n -e "$cyan Do you want to disable password for SSH login? [Yes] $clearColor"
read choice

if [[ $choice =~ ^[Yy]$ ]]; then # =~ for regex 
    disable_passwd
fi


### CHANGING DEFAULT PORT
choice="n"
echo -n -e "$cyan Do you want to change the default port of SSH? [No] $clearColor"
read choice

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "$cyan Enter new port: "
    read port
    change_port
    echo -e "$blueHigh Use following command to login: $clearColor"
    echo -e "$cyan ssh -p $port $user@$ip"
fi

choice="n"
echo -n -e "$cyan Do you want to disable root login? [No] $clearColor"
read choice
if [[ $choice =~ ^[Yy]$ ]]; then
    disable_root
fi

# choice="n"
# echo -n -e "$cyan Restrict SSH access to limited users? [default Yes] Y/N $clearColor"
# read choice
# if [[ $choice =~ ^[Yy]$ ]]; then
#     user_access
# fi
