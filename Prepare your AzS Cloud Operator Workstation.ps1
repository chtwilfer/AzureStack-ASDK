## Setup an Azure Stack Cloud Operator and Developer Workstation Environment
# Christian Twilfer
# 01.02.2018

## Install useful ASDK Host Apps
# Install SSH on Windows 10
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Chocolatey
Set-ExecutionPolicy Unrestricted -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Enable Choco Global Confirmation
Write-host "Enabling global confirmation to streamline installs"
choco feature enable -n allowGlobalConfirmation
# Visual Studio Code
Write-host "Installing VS Code with Chocolatey"
choco install visualstudiocode
# Putty
Write-host "Installing Putty with Chocolatey"
choco install putty.install
# WinSCP
Write-host "Installing WinSCP with Chocolatey"
choco install winscp.install 
# Chrome
Write-host "Installing Chrome with Chocolatey"
choco install googlechrome
# Azure CLI
choco install azure-cli
# Azure Storage Explorer
choco install microsoftazurestorageexplorer
# Download and install Git
choco install git 
# Install VS Code Extensions
code --install-extension ms-vscode.vscode-azureextensionpack
code --install-extension ms-vscode.powershell
# Upgrades
choco upgrade azure-cli
choco upgrade microsoftazurestorageexplorer

## Install Powershell
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted
Get-Module -ListAvailable | where-Object {$_.Name -like "Azure*"} | Uninstall-Module
# Install the AzureRM.Bootstrapper module. Select Yes when prompted to install NuGet 
Install-Module -Name AzureRm.BootStrapper -Force
Use-AzureRmProfile -Profile 2017-03-09-profile
Install-Module -Name AzureStack -RequiredVersion 1.2.11 -Force


## Install Azure Stack Tools
# Change directory to the root directory
cd \
# Download the tools archive
Invoke-WebRequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile master.zip
# Expand the downloaded files
Expand-Archive master.zip -DestinationPath . -Force
# Change to the tools directory
cd AzureStack-Tools-master


## Configure your environment
# Navigate to the downloaded folder and import the **Connect** PowerShell module
Set-ExecutionPolicy RemoteSigned
Import-Module .\Connect\AzureStack.Connect.psm1
# For Azure Stack development kit, this value is set to https://management.local.azurestack.external. For a real Azure Stack solution this will be https://maangement.-region-.-fqdn-
$ArmEndpoint = "Resource Manager endpoint for your environment"
# For Azure Stack development kit, this value is set to https://graph.windows.net/.
$GraphAudience = "GraphAudience endpoint for your environment"
# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment `
-Name "AzureStackUser" `
-ArmEndpoint $ArmEndpoint
# Set the GraphEndpointResourceId value
Set-AzureRmEnvironment `
-Name "AzureStackUser" `
-GraphAudience $GraphAudience
# Get the Active Directory tenantId that is used to deploy Azure Stack
$TenantID = Get-AzsDirectoryTenantId `
-AADTenantName "myDirectoryTenantName.onmicrosoft.com" `
-EnvironmentName "AzureStackUser"
# Sign in to your environment
Login-AzureRmAccount `
-EnvironmentName "AzureStackUser" `
-TenantId $TenantID
