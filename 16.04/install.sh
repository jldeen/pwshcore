#!/bin/bash
ver=1.0
psw=$(whiptail --title "Sudo Password Capture" --passwordbox "Sudo required to install. Please enter your sudo password to proceed." 10 60 3>&1 1>&2 2>&3)

function envSelection {
    choice=$(whiptail --title "Environment Selection" --menu "Please choose your environment" 16 78 5 \
    "ubuntu14" "14.04" \
    "ubuntu16" "16.04" \
    "ubuntu17" "17.04" 3>&2 2>&1 1>&3) 
    
    # Change to lower case and remove spaces.
    option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
    case "${option}" in
        ubuntu14) sudo -S <<< $psw installPSCore14
        ;;
        ubuntu16) sudo -S <<< $psw installPSCore16
        ;;
        ubuntu17) sudo -S <<< $psw installPSCore17
        ;;
        *) whiptail --title "PowerShell Core Installer" --msgbox "You cancelled or have finished." 8 78
            status=1
            exit
        ;;
    esac
}
function envSelectazrm {
    envSelection
    sudo -s <<< $psw installAzureRM
    exit 0 && echo "Completed install!"
}
function envselctall {
    envSelection
    sudo -s <<< $psw installAzureRM
    sudo -s <<< $psw installAzCli
    exit 0 && echo "Completed install"
}
function installPSCore14 {
    {
        # Import the public repository GPG keys
        curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        # Register the Microsoft Ubuntu repository
        curl https://packages.microsoft.com/config/ubuntu/14.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
        # Update apt-get
        sudo apt-get update
        # Install PowerShell
        sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
        sleep 1
        for ((i=0; i<=100; i+=20)); do
            sleep 1
            echo $i
        done
} | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 14.04" 6 60 0


#         echo 100
#         # Give it some time to display the progress to the user.
#         sleep 2
#     } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 14.04" 8 78 0
# }
function installPSCore16 {
    {
        # Import the public repository GPG keys
        curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        # Register the Microsoft Ubuntu repository
        curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
        # Update apt-get
        sudo apt-get update
        # Install PowerShell
        sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
        sleep 1
        for ((i=0; i<=100; i+=20)); do
            sleep 1
            echo $i
        done
    }   | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 16.04" 6 60 0
} 

function installPSCore17 {
   {
        i="0"
        while (true)
        do
            # Import the public repository GPG keys
            curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
            # Register the Microsoft Ubuntu repository
            curl https://packages.microsoft.com/config/ubuntu/17.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
            # Update apt-get
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell && echo "The latest version of Powershell Core has been installed..."
            sleep 1
            echo $i
            i=$(expr $i + 1)
        done
        # If it is done then display 100%
        echo 100
        # Give it some time to display the progress to the user.
        sleep 2
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 17.04" 8 78 0
}

function installAzureRM {
    {
     i="0"
        while (true)
        do
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
            echo
            sleep 1
            echo $i
            i=$(expr $i + 1)
        done
        # If it is done then display 100%
        echo 100
        # Give it some time to display the progress to the user.
        sleep 2
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing Azure RM Modules" 8 78 0
} 
function installAzCli {
    {
     i="0"
        while (true)
        do
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
            echo
            sleep 1
            echo $i
            i=$(expr $i + 1)
        done
        # If it is done then display 100%
        echo 100
        # Give it some time to display the progress to the user.
        sleep 2
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing Azurem CLI 2.0" 8 78 0
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
        a\ *) envSelection ;;
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