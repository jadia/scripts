#!/bin/bash
: '
Github installation and configure script
Author: Nitish Jadia
Date: 2019-01-16
Version: v1.0 There maybe numerous bug. Please open a issue or a pull request for the same.
'

#check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[96mThis script must be run as root\e[0m" 
   exit 1
fi 

echo -e "\e[96mAttempting to install git.\n\e[0m"
which git > /dev/null
if [[ "$?" == 0 ]]; then
    echo -e "\e[42mGithub already installed. Moving on...\e[0m"
elif [[ "$?" == 1 ]]; then
#		checkInternet()
    sudo apt-get install -y git
    echo -e "\e[42mGit installation done\e[0m"
else
    echo -e "\e[41m Installation Failed!\e[0m"
fi

echo -e "\e[96mDo you wish to set up github? \e[0m"
read choice
if ! [[ $choice =~ ^[Yy]$ ]]; then
    exit
fi
echo -e "\e[96m Your github credentials... \e[0m"
echo -n "[username]"
read username
git config --global user.name "$username"
echo ""
echo -n "[email]"
read email
git config --global user.email "$email"
echo -e "\e[96mSetting up SSH keys.\e[0m"
echo -e "\e[96m Please say \"yes\" when prompted to overwrite the id_rsa file.\e[0m"
echo -e "\e[96m Press [Enter] to continue...\e[0m"
read -n 1 -s
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -q -N ""
echo ""
echo -e "\e[44m Goto www.github.com and sign in. \e[0m"
echo -e "\e[44m Proceed to settings->Add SSH and GPG keys. \e[0m"
echo -e "\e[44m Click on New SSH keys green colored button. \e[0m"
echo -e "\e[44m Copy and paste the below key in there. \e[0m"
echo ""
cat ~/.ssh/id_rsa.pub
echo -e "\e[96m Press [Enter] to continue...\e[0m"
read -n 1 -s
echo -e "\e[96m Are you sure you have done the above tasks? Press [Enter] to continue.\e[0m"
read -n 1 -s
echo -e "\e[96m Testing if SSH keys are working or not. \e[0m"
$(ssh -i ~/.ssh/id_rsa  -o StrictHostKeyChecking=no -T git@github.com)
if [[ $? -eq 255 ]]; then
    echo -e "\e[41m Error with SSH configuration!\e[0m"
fi
echo ""
echo -e "\e[96m Proceed to github to make a new repository and clone it using git clone command. \e[0m"
echo ""
echo -e "\e[96m Thank you! \e[0m"