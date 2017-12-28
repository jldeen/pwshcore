#!/bin/bash
# script version
ver=1.2
#SUSE Whiptail Pre-Req Install 
if [ -f /etc/SuSE-release ] ; then
    whiptail > /dev/null 2>&1
    exitstatus=$?
        if [ $exitstatus != 0 ]; then
        echo "Whiptail not found. Whiptail is required for this PowerShell Installation GUI Script."
        echo
        read -p "Press enter to install Whiptail..."
        echo
        echo "Now installing Newt package with Whiptail..."
        echo
        echo
        echo "Please wait..."
        sudo zypper --non-interactive install newt && echo "Successfully installed Newt with Whiptail. PowerShell Core Install script will now proceed."
        echo 
        echo
        fi
    else 
    do_main_menu
fi

### Begin GUI install...
# passwd capture function
function capturePass {
    # password capture
    psw=$(whiptail --title "PowerShell Core Install | Sudo Password Capture" --passwordbox "Sudo is required to install PowerShell Core. Please enter your sudo password to proceed with the install." 10 60 3>&1 1>&2 2>&3)
    exitstatus=$?
        if [ $exitstatus = 0 ]; then
            whiptail --title "PowerShell Core Installation" --msgbox "Sudo password captured successfully!" 8 78
        else
            #Password if cancelled
            whiptail --title "PowerShell Core Installation" --msgbox "Sudo password not captured, install cancelled." 10 60
        fi
}
# sudo check
sudo=$(whoami | grep root)
exitstatus=$?
if [ $exitstatus = 0 ]; then
        whiptail --title "PowerShell Core Installation" --msgbox "Sudo password not required. Install being run as root." 10 60
    else
        whiptail --title "PowerShell Core Installation" --msgbox "Sudo password required!" 8 78
        capturePass
fi
function envSelection {
    choice=$(whiptail --title "Environment Selection" --menu "Please choose your environment" 16 78 5 \
    "ubuntu14" "14.04" \
    "ubuntu16" "16.04" \
    "ubuntu17" "17.04" \
    "debian8" "Debian 8" \
    "debian9" "Debian 9" \
    "opensuse42" "OpenSUSE 42" \
    "centos7" "CentOS 7" \
    "rhel7" "RHEL 7" \
    "back" "Back to main menu" 3>&2 2>&1 1>&3) 
    # Change to lower case and remove spaces.
    option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
    case "${option}" in
        ubuntu14) installPSCore14
        ;;
        ubuntu16) installPSCore16
        ;;
        ubuntu17) installPSCore17
        ;;
        debian8) installDebian8
        ;;
        debian9) installDebian9
        ;;
        opensuse42) installOpenSuse42
        ;;
        centos7) installCentos7
        ;;
        rhel7) installrhel7
        ;;
        back) do_main_menu
        ;;
        *) whiptail --title "PowerShell Core Installer" --msgbox "You have chosen to cancel this installation." 8 78
            status=1
            exit
        ;;
    esac
}
function envSelectazrm {
    envSelection
    installAzureRM
    end
    exit 0
}
function envselctall {
    envSelection
    installAzureRM
    azCliCheck
    end
    exit 0
}
function optInstall {
    choice=$(whiptail --title "Optional Features" --menu "Please choose which components you would like to install" 16 78 5 \
    "azureRM" "AzureRM Modules" \
    "azureCli" "Azure CLI 2.0" \
    "back" "" 3>&2 2>&1 1>&3) 
        case $choice in
            azureRM) installAzureRM
            ;;
            azureCli) azCliCheck
            ;;
            back) do_main_menu
            ;;
            *) whiptail --title "PowerShell Core Installer" --msgbox "You have chosen to cancel this installation." 8 78
                status=1
                exit
            ;;
        esac
}
function installDebian8 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Install system components
            sudo apt-get update
            sudo apt-get install apt-transport-https -y
            # Import the public repository GPG keys
            curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - > /dev/null 2>&1
            # Register the Microsoft Product feed
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main" > /etc/apt/sources.list.d/microsoft.list'
            # Update the list of products
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell
            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Debian 8" 6 60 0
    end
} 
function installDebian9 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Install system components
            sudo -S <<< $psw apt-get update
            sudo -S <<< $psw apt-get install gnupg apt-transport-https dirmngr -y
            # Import the public repository GPG keys
            curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - > /dev/null 2>&1
            # Register the Microsoft Product feed
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/microsoft.list'
            # Update the list of products
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell
            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Debian 9" 6 60 0
    end
} 
function installOpenSuse42 {
    {
        for ((i=0; i<=100; i+=20)); do
            # Pre-reqs
            sudo zypper --non-interactive install \
            glibc-locale \
            glibc-i18ndata \
            tar \
            curl \
            libunwind \
            libicu \
            openssl > /dev/null 2>&1
            sudo zypper --non-interactive clean --all > /dev/null 2>&1

            # Install
            release=`curl -s https://api.github.com/repos/powershell/powershell/releases/latest | sed '/tag_name/!d' | sed s/\"tag_name\"://g | sed s/\"//g | sed s/v//g | sed s/,//g | sed s/\ //g`

            #DIRECT DOWNLOAD
            pwshlink=/usr/bin/pwsh
            package=powershell-${release}-linux-x64.tar.gz
            downloadurl=https://github.com/PowerShell/PowerShell/releases/download/v$release/$package

            curl -L -o "$package" "$downloadurl" > /dev/null 2>&1

            ## Create the target folder where powershell will be placed
            sudo mkdir -p /opt/microsoft/powershell/$release
            ## Expand powershell to the target folder
            sudo tar zxf $package -C /opt/microsoft/powershell/$release > /dev/null 2>&1

            ## Change the mode of 'pwsh' to 'rwxr-xr-x' to allow execution
            sudo chmod 755 /opt/microsoft/powershell/$release/pwsh
            ## Create the symbolic link that points to powershell
            sudo ln -sfn /opt/microsoft/powershell/$release/pwsh $pwshlink

            ## Add the symbolic link path to /etc/shells
            if [ ! -f /etc/shells ] ; then
                echo $pwshlink | sudo tee /etc/shells ;
            else
                grep -q "^${pwshlink}$" /etc/shells || echo $pwshlink | sudo tee --append /etc/shells > /dev/null ;
            fi

            ## Remove the downloaded package file
            rm -f $package

            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for OpenSUSE" 6 60 0
    end
}
function installCentos7 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Register the Microsoft RedHat repository
            curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo > /dev/null 2>&1
            # Install PowerShell
            sudo yum install -y powershell
            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for CentOS 7" 6 60 0
    end
}
function installrhel7 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Repodata 
            sudo yum makecache fast > /dev/null 2>&1
            # Register the Microsoft RedHat repository
            curl -s https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
            # Install PowerShell
            sudo yum install -y powershell
            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for RHEL 7" 6 60 0
    end
} 
function installPSCore14 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Import the public repository GPG keys
            curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
            # Register the Microsoft Ubuntu repository
            curl -s https://packages.microsoft.com/config/ubuntu/14.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
            # Update apt-get
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell
            sleep 1
            echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 14.04" 6 60 0
    end
} 
function installPSCore16 {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Import the public repository GPG keys
            curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
            # Register the Microsoft Ubuntu repository
            curl -s https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
            # Update apt-get
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell
            sleep 1
            echo $i
        done
    }   | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 16.04" 6 60 0
    end
} 
function installPSCore17 {
   {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            # Import the public repository GPG keys
            curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - > /dev/null 2>&1
            # Register the Microsoft Ubuntu repository
            curl -s https://packages.microsoft.com/config/ubuntu/17.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
            # Update apt-get
            sudo apt-get update
            # Install PowerShell
            sudo apt-get install -y powershell
            sleep 1
            echo $i
        done
    }   | whiptail --title "PowerShell Core Installer" --gauge "Installing PowerShell Core for Ubuntu 17.04" 6 60 0
    end
} 
function installAzureRM {
    {
        for ((i=0; i<=100; i+=20)); do
        # sudo -S - auth sudo in advance
        sudo -S <<< $psw ls > /dev/null 2>&1
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
        sleep 1
        echo $i
        done
    } | whiptail --title "PowerShell Core Installer" --gauge "Installing Azure RM Modules" 8 78 0
}
function rpmAzInstall {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
            yum check-update > /dev/null 2>&1
            sudo yum install azure-cli -y
            sleep 1
            echo $i
        done
        } | whiptail --title "PowerShell Core Installer" --gauge "Installing Azure CLI 2.0 for RPM" 6 60 0
}
function zypAzInstall {
    {
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/azure-cli.repo'
            sudo zypper refresh > /dev/null 2>&1
            sudo zypper install azure-cli
            sleep 1
            echo $i
        done
        } | whiptail --title "PowerShell Core Installer" --gauge "Installing Azure CLI 2.0 for RPM" 6 60 0
}
function installAzCli {
    {  
        for ((i=0; i<=100; i+=20)); do
            # sudo -S - auth sudo in advance
            sudo -S <<< $psw ls > /dev/null 2>&1
            echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
            sudo tee /etc/apt/sources.list.d/azure-cli.list > /dev/null 2>&1
            sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 > /dev/null 2>&1
            sudo apt-get install -y apt-transport-https
            sudo apt-get update && sudo apt-get install azure-cli -y 
            if [[ $? -eq 0 ]]
            then
                echo "Successfully installed Azure CLI 2.0"
            else
                echo "Azure CLI 2.0 not installed successfully" >&2
            fi
            sleep 1
            echo $i
        done
    }   | whiptail --title "PowerShell Core Installer" --gauge "Installing Azure CLI 2.0" 6 60 0  
}

# Package Management Check
function azCliCheck {
    # Debian
    if [ -f /etc/debian_version ]; then
    installAzCli
    # Rhel
    elif [ -f /etc/redhat-release ]; then
    rpmAzInstall
    # Suse
    elif [ -f /etc/SuSE-release ]; then 
    zypAzInstall
    else
        echo "Cannot install Azure CLI. Package manager could not be determeined. Please open an issue." > ~/err_pwshcore.log
    fi
}          
function about {
  whiptail --title "About" --msgbox " \
                PowerShell Core Install Menu Assist
                      Written by Jessica Deen
    This menu will help install the latest version of PowerShell 
    Core and optional components if desired.
    For additional details see: https://github.com/jldeen/pwshcore
    " 35 70 35
}
function end {
    whiptail --title "PowerShell Core Installation" --msgbox "PowerShell Core Installer has completed successfully." 8 78
}
#------------------------------------------------------------------------------
function do_main_menu ()
    {
    SELECTION=$(whiptail --title "PowerShell Core Install Assist $ver" --menu "Arrow/Enter Selects or Tab Key" 20 70 10 --cancel-button Quit --ok-button Select \
    "a " "PowerShell Core Install Only" \
    "b " "PowerShell Core Install + AzureRM Modules" \
    "c " "PowerShell Core Install + AzureRM Modules and Azure CLI 2.0" \
    "d " "Optional Components Menu" \
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
        d\ *) optInstall ;;
        f\ *) about ;;
        q\ *) exit 0 ;;
            *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
        esac || whiptail --msgbox "There was an error running selection $SELECTION" 20 60 1
    fi
    }
while true; do
   do_main_menu
done