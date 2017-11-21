#!/bin/bash

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

echo "This script will now install the AzureRM Modules..."
echo .

#Azure RM NetCore Preview Module Install
sudo pwsh -Command {Install-Module -Name AzureRM.Netcore}
sudo pwsh -Command {Import-Module -Name AzureRM.Netcore}

if [[ $? -eq 0 ]]
    then
        echo "Successfully installed PowerShell Core with AzureRM NetCore Preview Module."
    else
        echo "PowerShell Core with AzureRM NetCore Preview Module did not install successfully." >&2
fi

#Install Azure CLI 2.0
#Address https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#Github https://github.com/Azure/azure-cli/releases

read -p "Would you also like to install Azure CLI? y/n" -n 1 -r
echo .

if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Update homebrew
    brew update

    # Install AZ Cli
    brew install azure-cli

    if [[ $? -eq 0 ]]
    then
        echo "Successfully installed Azure CLI 2.0"
    else
        echo "Azure CLI 2.0 not installed successfully" >&2
fi
else 
    echo "You chose not to install Azure CLI 2.0... Exiting now."
fi