#!/bin/bash
ver=1.0

function envSelection {
    choice=$(whiptail --title "Environment Selection" --menu "Please choose your environment" 16 78 5 \
    "ubuntu14" "14.04" \
    "ubuntu16" "16.04" \
    "ubuntu17" "17.04" \
    "macOS" "10.12+" 3>&2 2>&1 1>&3) 
    
    # Change to lower case and remove spaces.
    option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
    case "${option}" in
        ubuntu14) installPSCore14 | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 14.04" 20 70 0
        ;;
        ubuntu16) installPSCore16 | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 16.04" 20 70 0
        ;;
        ubuntu17) installPSCore17 | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 14.04" 20 70 0
        ;;
        macos) installmacOS | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for macOS 10.12+" 20 70 0
        ;;
        *) whiptail --title "PowerShell Core Installer" --msgbox "You cancelled or have finished." 8 78
            status=1
            exit
        ;;
    esac
}
function installPSCore14 {
    echo "This script will install the latest version of PowerShell Core on your Ubuntu 16.04 system...."
    echo .

    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    curl https://packages.microsoft.com/config/ubuntu/14.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list

    # Update apt-get
    sudo apt-get update

    # Install PowerShell
    echo .
    sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
    echo .

}
function installPSCore16 {
    echo "This script will install the latest version of PowerShell Core on your Ubuntu 16.04 system...."
    echo .

    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list

    # Update apt-get
    sudo apt-get update

    # Install PowerShell
    echo .
    sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
    echo .

}
function installPSCore17 {
    echo "This script will install the latest version of PowerShell Core on your Ubuntu 16.04 system...."
    echo .

    # Import the public repository GPG keys
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

    # Register the Microsoft Ubuntu repository
    curl https://packages.microsoft.com/config/ubuntu/17.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list

    # Update apt-get
    sudo apt-get update

    # Install PowerShell
    echo .
    sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
    echo .

}
function installmacOS {
    echo "This script will first install brew if you do not already have it..."
    echo .

    #brew install
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # caskroom install
    brew tap caskroom/cask

    echo "This script will now install the latest version of PowerShell Core via brew..."
    echo .

    # brew powershell core install
    brew cask install powershell && echo "The latest version of PowerShell Core has been installed."
}
function envSelectazrm {
    envSelection
    installAzureRM | whiptail --title "Azure RM Modules Installer" --gauge "Installing Azure RM Modules" 20 70 0
    exit 0 && echo "Completed install!"
}
function envselctall {
    envSelection
    installAzureRM | whiptail --title "Azure RM Modules Installer" --gauge "Installing Azure RM Modules" 20 70 0
    installAzCli | whiptail --title "Azure CLI 2.0 Installer" --gauge "Installing Azure CLI 2.0" 20 70 0
    exit 0 && echo "Completed install"
}
function installAzureRM {
    echo "This script will now install the AzureRM Modules..."
    echo .

    #Azure RM NetCore Preview Module Install
    sudo pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    sudo pwsh -Command Install-Module -Name AzureRM.Netcore
    sudo pwsh -Command Import-Module -Name AzureRM.Netcore

    if [[ $? -eq 0 ]]
        then
            echo "Successfully installed PowerShell Core with AzureRM NetCore Module."
        else
            echo "PowerShell Core with AzureRM NetCore Module did not install successfully." >&2
    fi
}
function installAzCli {
    #Install Azure CLI 2.0
    #Address https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    #Github https://github.com/Azure/azure-cli/releases

    read -p "Would you also like to install Azure CLI? y/n" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
        sudo apt-get install apt-transport-https
        sudo apt-get update && sudo apt-get install azure-cli
        if [[ $? -eq 0 ]]
        then
            echo "Successfully installed Azure CLI 2.0"
        else
            echo "Azure CLI 2.0 not installed successfully" >&2
    fi
    else 
        echo "You chose not to install Azure CLI 2.0... Exiting now."
    fi
}
function about {
  whiptail --title "About" --msgbox " \
                PowerShell Core Install Menu Assist
                  written by Jessica Deen
    This Menu will help install the latest version of PowerShell Core and optional components
    Run Menu Pick Selections in order and verify successful completion
    before progressing to next step. 
    For Additional Details See https://github.com/jldeen/pwshcore
    " 35 70 35

}

#------------------------------------------------------------------------------
function do_main_menu ()
    {
    SELECTION=$(whiptail --title "PowerShell Core Install Assist $ver" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
    "a " "PowerShell Core Install Only" \
    "b " "PowerShell Core Install + AzureRM Modules" \
    "c " "PowerShell Core Install + AzureRM Modules and Azure CLI 2.0" \
    "f " "About" \
    "q " "Quit Menu Back to Console"  3>&1 1>&2 2>&3)

    RET=$?
    if [ $RET -eq 1 ]; then
        exit 0
    elif [ $RET -eq 0 ]; then
        case "$SELECTION" in
        a\ *) envSelection;;
        b\ *) envSelectazrm ;;
        c\ *) envselctall ;;
        f\ *) about ;;
        q\ *) echo "NOTE"
                echo "After PowerShell Core Installation is Complete"
                echo "      Reboot to Finalize Install"
                echo "      Then test PowerShell Core by typing 'pwsh'"
                echo ""
                exit 0 ;;
            *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
        esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
    fi
    }

while true; do
   do_main_menu
done