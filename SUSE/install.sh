#!/bin/bash
echo "This script will install the latest version of PowerShell Core on your OpenSUSE system...."
echo
echo
# PowerShell Install
    # sudo -S - auth sudo in advance
    sudo -S <<< $psw ls > /dev/null 2>&1
    # Register the Microsoft signature key
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    # Add the Microsoft Product feed
    curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/zypp/repos.d/microsoft.repo > /dev/nuyll 2>&1
    # Update the list of products
    sudo zypper update
    # Install PowerShell
    echo
    echo
    echo "When installing PowerShell Core, OpenSUSE may report that nothing provides libcurl. libcurl should already be installed on supported versions of OpenSUSE. Run zypper search libcurl to confirm. The error will present 2 'solutions'. Choose 'Solution 2' to continue installing PowerShell Core."
    echo
    echo
    read -p "Press enter to continue..."
    echo 
    echo
    sudo zypper install powershell && echo "The latest version of Powershell Core has been installed..."

#Azure RM NetCore Preview Module Install
    echo
    echo "This script will now install the AzureRM Modules..."
    echo
    echo
    sudo pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    sudo pwsh -Command Install-Module -Name AzureRM.Netcore
    sudo pwsh -Command Import-Module -Name AzureRM.Netcore
    if [[ $? -eq 0 ]]
        then
            echo "Successfully installed PowerShell Core with AzureRM NetCore Module."
        else
            echo "PowerShell Core with AzureRM NetCore Module did not install successfully." >&2
    fi

#Install Azure CLI 2.0
    #Address https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
    #Github https://github.com/Azure/azure-cli/releases
    echo
    echo
    read -p "Would you also like to install Azure CLI? y/n " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # sudo -S - auth sudo in advance
        sudo -S <<< $psw ls > /dev/null 2>&1
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/azure-cli.repo'
        sudo zypper refresh > /dev/null 2>&1
        sudo zypper install azure-cli
    else 
        echo "You chose not to install Azure CLI 2.0... Exiting now."
    fi