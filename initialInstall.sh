#!/bin/bash
script_path="$(pwd)/initialInstall.sh"

#check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[44mThis script must be run as root\e[0m" 
   exit 1
fi 

echo -e "\e[44mInstallation will start right after update\e[0m"
#sudo apt-get update -y

#-------Functions------#



# ------Installation functions------------#

function install_chrome()
{
	echo -e "\e[44mAttempting to install Chrome.\n\e[0m"
	which google-chrome-stable 2>&1|tee 1> /dev/null
	if [[ "$?" == 0 ]]; then
		echo -e "\e[42mGoogle Chrome already installed. Moving on...\e[0m"
	else
#		checkInternet()
		wget -c "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" -P /tmp
		sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb
		echo -e "\e[42mGoogle Chrome installed\e[0m"
	fi
}

function install_vim()
{
        echo -e "\e[44mAttempting to install vim.\e[0m"
        which vim 2>&1|tee 1> /dev/null
#	which vim
        if [[ "$?" == 0 ]]; then
                echo -e "\e[42mVim already installed. Moving on...\e[0m"
        else
 #               checkInternet()
                sudo apt-get install -y vim
		echo -e "\e[42mVim installed\e[0m"
        fi
}

function install_vscode()
{
	echo -e "\e[44mAttempting to install VScode.\e[0m"
#        which code 2>&1|tee 1> /dev/null
	which code
        if [[ "$?" == 0 ]]; then
                echo -e "\e[42mVScode already installed. Moving on...\e[0m"
        else
 #               checkInternet()
 		wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
		sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
                sudo apt-get install -y code
                echo -e "\e[42mVScode installed\e[0m"
        fi

}

function install_python3()
{
	echo -e "\e[44mAttempting to install Python3.\e[0m"
#        which python3 2>&1|tee 1> /dev/null
	which python3 > /dev/null
        if [[ "$?" == 0 ]]; then
                echo -e "\e[42mPython3 already installed. Moving on...\e[0m"
        else
 #               checkInternet()
 		sudo apt-get install -y python3
                if [[ "$?" == 0 ]]; then
                        echo -e "\e[42mPython installed\e[0m"
                else
                        echo -e "\e[42Installation failed\e[0m"
                fi
        fi

}

#------ main -------#
choice="y"
echo -e "\e[36mDo you want to install chrome? [Y/n]\e[0m"
if [[ $1 != "--all" ]]; then
	read choice
fi
if [[ $choice =~ ^[Yy]$ ]]; then
	install_chrome
fi
echo ""
echo -e "\e[36mDo you want to install vim? [Y/n]\e[0m"
if [[ $1 != "--all" ]]; then
        read choice
fi
if [[ $choice =~ ^[Yy]$ ]]; then
	install_vim
fi
echo -e "\e[36mDo you want to install vsCode? [Y/n]\e[0m"
if [[ $1 != "--all" ]]; then
        read choice
fi
if [[ $choice =~ ^[Yy]$ ]]; then
        install_vscode
fi
echo ""

echo -e "\e[36mDo you want to install Python3? [Y/n]\e[0m"
if [[ $1 != "--all" ]]; then
        read choice
fi
if [[ $choice =~ ^[Yy]$ ]]; then
        install_python3
fi
echo ""


echo -e "\e[44mThank you\e[0m"
