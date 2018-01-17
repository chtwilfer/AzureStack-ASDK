## Connecting to Azure Stack using Azure Powershell

#After completing this exercise, you have connected to the MAS Admin and Tenant endpoints using PowerShell.
#Install and configure prerequisites for Azure Stack compatible Azure PowerShell modules
#Install Azure Stack compatible Azure PowerShell modules
#Download Azure Stack tools from GitHub
#Configure the Azure Stack PowerShell environment
#Retrieve the GUID value of the Azure Active Directory or Active Directory instance associated with the Azure Stack instance
#Connect to the Admin and Tenant endpoints of your MAS deployment using PowerShell
#Verify you have connected to the MAS Admin and Tenant endpoints using PowerShell


## install Azure Stack modules
Install-Module -Name AzureRm.BootStrapper
Use-AzureRmProfile -Profile 2017-03-09-profile -Force
Install-Module -Name AzureStack -RequiredVersion 1.2.10
Get-Module –ListAvailable | Where-Object Name –like ‘Azure*’


## Download Azure Stack Tools
Set-Location –Path ‘C:\’
Invoke-WebRequest –Uri <a href="https://github.com/Azure/AzureStack-Tools/archive/master.zip" title="" target="_blank">https://github.com/Azure/AzureStack-Tools/archive/master.zip</a> `
  -OutFile master.zip
Expand-Archive –Path .\master.zip –DestinationPath . -Force
Set-Location –Path C:\AzureStack-Tools-master


## Configure the Azure Stack Powershell Environment
Import-Module –Name .\Connect\AzureStack.Connect.psm1
Add-AzureRmEnvironment –Name ‘AzureStackAdmin’ 
#x200e -ArmEndpoint ‘https://adminmanagement.local.azurestack.external’
Add-AzureRmEnvironment –Name ‘AzureStackUser’  
#x200e -ArmEndpoint ‘https://adminmanagement.local.azurestack.external’

# By using AAD
Set-AzureRmEnvironment -Name ‘AzureStackAdmin’ -GraphAudience ‘https://graph.windows.net’ 
Set-AzureRmEnvironment -Name ‘AzureStackUser’ -GraphAudience ‘https://graph.windows.net’
$tenantID = Get-AzsDirectoryTenantId -AADTenantName <adminAADTenantName> -EnvironmentName ‘AzureStackAdmin’
$tenantID = Get-AzsDirectoryTenantId -AADTenantName <adminAADTenantName> -EnvironmentName ‘AzureStackUser’

# By using AD FS
Set-AzureRmEnvironment -Name ‘AzureStackAdmin’ -GraphAudience ‘https://graph.local.azurestack.external/’ -EnableAdfsAuthentication:$true
Set-AzureRmEnvironment -Name ‘AzureStackUser’ -GraphAudience ‘https://graph.local.azurestack.external/’ -EnableAdfsAuthentication:$true
$tenantID = Get-AzsDirectoryTenantId -ADFS -EnvironmentName ‘AzureStackAdmin’
$tenantID = Get-AzsDirectoryTenantId -ADFS -EnvironmentName ‘AzureStackUser’


## Connect to Azure Stack Endpoints
$adminUserName = ‘AzureStackAdmin@azurestack.local’
$adminPassword = ‘Pa55w.rd’ | ConvertTo-SecureString –Force –AsPlainText
$adminCredential = New-Object PSCredential($adminUserName,$adminPassword)
Login-AzureRmAccount –EnvironmentName ‘AzureStackAdmin’ -TenantId $tenantID -Credential $adminCredential

# Sign in to Endpoint
$tenantUserName = ‘T1U1@azurestack.local’
$tenantPassword = ‘Pa55w.rd’ | ConvertTo-SecureString –Force –AsPlainText
$tenantCredential = New-Object PSCredential($tenantUserName,$tenantPassword)
Login-AzureRmAccount –EnvironmentName ‘AzureStackUser’ -TenantId $tenantID -Credential $tenantCredential 


