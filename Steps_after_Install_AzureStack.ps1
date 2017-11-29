<#
 .SYNOPSIS
    Configurering AzureStack after Installation.

 .DESCRIPTION
    The Steps:

    1. Reset the password expiration to 180 days
    2. Register Azure Stack with your Azure Subscription
    3. Connect to AzureStack
  
 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    16.11.2017 
  Purpose/Change:   Initial script development

  There are the necessary files and folders on the network share. These are copied according to the script to the C drive
  It is required that in the run-up to the current ASDK is downloaded, unpacked and is uploaded on the share

#>

# Reset the password expiration to 180 days
Set-ADDefaultDomainPasswordPolicy -MaxPasswordAge 180.00:00:00 -Identity azurestack.local

# Overall Process for combining AzS to Azure

# Install Powershell
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted
Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module

# Install the AzureRM.Bootstrapper module. Select Yes when prompted to install NuGet 
Install-Module `
  -Name AzureRm.BootStrapper

# Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
Use-AzureRmProfile `
  -Profile 2017-03-09-profile -Force
Install-Module `
  -Name AzureStack `
  -RequiredVersion 1.2.10
 
# Login to Azure
Login-AzureRmAccount -EnvironmentName "AzureCloud"
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack

# Import Register Module
Import-Module c:\temp\RegisterWithAzure.psm1 -Force -Verbose

# Register
Add-AzsRegistration -CloudAdminCredential azurestack\azurestackadmin -AzureDirectoryTenantName [yourTenantName] -AzureSubscriptionId [yourSubscriptionID] -PrivilegedEndpoint AzS-ERCS01 -BillingModel Development




