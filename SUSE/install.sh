#!/bin/bash
echo "This script will install the latest version of PowerShell Core on your OpenSUSE system...."
echo
echo
# PowerShell Install
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
        sudo zypper --gpg-auto-import-keys --no-gpg-checks -q refresh
        sudo zypper --non-interactive -q install azure-cli
    else 
        echo "You chose not to install Azure CLI 2.0... Exiting now."
    fi