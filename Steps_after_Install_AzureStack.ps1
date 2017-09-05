<#
 .SYNOPSIS
    Configurering AzureStack after Installation.

 .DESCRIPTION
    The Steps:

    1. Reset the password expiration to 180 days
    2. Register Azure Stack with your Azure Subscription
    3. Connect to AzureStack via Remote Desktop
    4. Make virtual machines available to your Azure Stack users
    5. Install PowerShell for Azure Stack
    6. Uninstall existing versions of PowerShell
    7. Install PowerShell in a disconnected or in a partially connected scenario
    8. Download Azure Stack tools from GitHub
    9. Active Directory Federation Services (AD FS) based deployments
    10. Register resource providers
    11. Test the connectivity
    12. Configure the Azure Stack operator's PowerShell environment
    13. Test the connectivity
    14. Deploy templates in Azure Stack using PowerShell
    

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    05.09.2017 
  Purpose/Change:   Initial script development

  There are the necessary files and folders on the network share. These are copied according to the script to the C drive
  It is required that in the run-up to the current ASDK is downloaded, unpacked and is uploaded on the share

#>


# Reset the password expiration to 180 days
# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-run-powershell-script#reset-the-password-expiration-to-180-days


# Register Azure Stack with your Azure Subscription
# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-register

# Connect to AzureStack via Remote Desktop
# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-connect-azure-stack


# Make virtual machines available to your Azure Stack users
# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-tutorial-tenant-vm


# Install PowerShell for Azure Stack
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted


# Uninstall existing versions of PowerShell
Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module
<#
Sign in to the development kit, or to the Windows-based external client if you are planning to establish a VPN connection. 
Delete all the folders that start with "Azure" from the C:\Program Files (x86)\WindowsPowerShell\Modules and 
C:\Users\AzureStackAdmin\Documents\WindowsPowerShell\Modules folders. 
Deleting these folders removes any existing PowerShell modules from the "AzureStackAdmin" and "global" user scopes.
#>


# Install PowerShell in a disconnected or in a partially connected scenario
$Path = "<Path that is used to save the packages>"
Save-Package -ProviderName NuGet -Source https://www.powershellgallery.com/api/v2 -Name AzureRM -Path $Path -Force -RequiredVersion 1.2.10
Save-Package -ProviderName NuGet -Source https://www.powershellgallery.com/api/v2 -Name AzureStack -Path $Path -Force -RequiredVersion 1.2.10

$SourceLocation = "<Location on the development kit that contains the PowerShell packages>"
$RepoName = "MyNuGetSource"
Register-PSRepository -Name $RepoName -SourceLocation $SourceLocation -InstallationPolicy Trusted
Install-Module AzureRM -Repository $RepoName
Install-Module AzureStack -Repository $RepoName


# Download Azure Stack tools from GitHub
# Change directory to the root directory 
cd \
# clone the repository
git clone https://github.com/Azure/AzureStack-Tools.git --recursive
# Change to the tools directory
cd AzureStack-Tools


# Change directory to the root directory 
cd \
# Download the tools archive
invoke-webrequest https://github.com/Azure/AzureStack-Tools/archive/master.zip -OutFile master.zip
# Expand the downloaded files
expand-archive master.zip -DestinationPath . -Force
# Change to the tools directory
cd AzureStack-Tools-master



# Active Directory Federation Services (AD FS) based deployments
# Navigate to the downloaded folder and import the **Connect** PowerShell module
Set-ExecutionPolicy RemoteSigned
Import-Module .\Connect\AzureStack.Connect.psm1

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment -Name "AzureStackUser" -ArmEndpoint "https://management.local.azurestack.external"

# Set the GraphEndpointResourceId value
Set-AzureRmEnvironment -Name "AzureStackUser" -GraphAudience "https://graph.local.azurestack.external/" -EnableAdfsAuthentication:$true

# Get the Active Directory tenantId that is used to deploy Azure Stack     
$TenantID = Get-AzsDirectoryTenantId -ADFS -EnvironmentName "AzureStackUser"

# Sign in to your environment
Login-AzureRmAccount -EnvironmentName "AzureStackUser" -TenantId $TenantID


# Register resource providers
foreach($s in (Get-AzureRmSubscription)) {
        Select-AzureRmSubscription -SubscriptionId $s.SubscriptionId | Out-Null
        Write-Progress $($s.SubscriptionId + " : " + $s.SubscriptionName)
Get-AzureRmResourceProvider -ListAvailable | Register-AzureRmResourceProvider -Force
}

# Test the connectivity
New-AzureRmResourceGroup -Name "MyResourceGroup" -Location "Local"


# Configure the Azure Stack operator's PowerShell environment
# Active Directory Federation Services (AD FS) based deployments
# Navigate to the downloaded folder and import the **Connect** PowerShell module
Set-ExecutionPolicy RemoteSigned
Import-Module .\Connect\AzureStack.Connect.psm1

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment -Name "AzureStackAdmin" -ArmEndpoint "https://adminmanagement.local.azurestack.external"
# Set the GraphEndpointResourceId value
Set-AzureRmEnvironment -Name "AzureStackAdmin" -GraphAudience "https://graph.local.azurestack.external/" -EnableAdfsAuthentication:$true
# Get the Active Directory tenantId that is used to deploy Azure Stack     
$TenantID = Get-AzsDirectoryTenantId -ADFS -EnvironmentName "AzureStackAdmin"
# Sign in to your environment
Login-AzureRmAccount -EnvironmentName "AzureStackAdmin" -TenantId $TenantID

# Test the connectivity
New-AzureRmResourceGroup -Name "MyResourceGroup" -Location "Local"


# Deploy templates in Azure Stack using PowerShell
<#
Go to http://aka.ms/AzureStackGitHub, search for the 101-simple-windows-vm template, 
and save it to the following location: c:\templates\azuredeploy-101-simple-windows-vm.json.
#>
# Set Deployment Variables
$myNum = "001" #Modify this per deployment
$RGName = "myRG$myNum"
$myLocation = "local"

# Create Resource Group for Template Deployment
New-AzureRmResourceGroup -Name $RGName -Location $myLocation

# Deploy Simple IaaS Template
New-AzureRmResourceGroupDeployment -Name myDeployment$myNum -ResourceGroupName $RGName -TemplateFile c:\templates\azuredeploy-101-simple-windows-vm.json -NewStorageAccountName mystorage$myNum -DnsNameForPublicIP mydns$myNum -AdminUsername <username> -AdminPassword ("<password>" | ConvertTo-SecureString -AsPlainText -Force) -VmName myVM$myNum -WindowsOSVersion 2012-R2-Datacenter
