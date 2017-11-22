#!/bin/bash

whiptail --title "PowerShell Core Installer" --yesno --defaultyes "Install latest version of PowerShell Core" 8 78
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    status="0"
    while [ "$status" -eq 0 ]  
    do
        choice=$(whiptail --title "Environment Selection" --menu "Please choose your environment" 16 78 5 \
        "ubuntu14" "14.04" OFF\
        "ubuntu16" "16.04" ON \
        "ubuntu17" "17.04" OFF \
        "macOS" "macOS" OFF 3>&2 2>&1 1>&3) 
         
        # Change to lower case and remove spaces.
        option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
        case "${option}" in
            ubuntu14) 
                whiptail --title "Ubuntu 14.40 PowerShelL Core Install" --msgbox "In first option" 8 78
            ;;
            ubuntu16)
                whiptail --title "Ubuntu 16.40 PowerShelL Core Install" --msgbox "In second option" 8 78
            ;;
            ubuntu17)
                whiptail --title "Ubuntu 17.40 PowerShelL Core Install" --msgbox "In second option" 8 78
            ;;
            macos)
                whiptail --title "macOS PowerShelL Core Install" --msgbox "In second option" 8 78
            ;;
            *) whiptail --title "PowerShell Core Installer" --msgbox "You cancelled or have finished." 8 78
                status=1
                exit
            ;;
        esac
        exitstatus1=$status1
    done
else
    whiptail --title "PowerShell Core Installer" --msgbox "You chose not to proceed." 8 78
    exit
fi

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