## Add a Linux operating system image to Azure Stack in the Diconnected Mode


## Create a folder and save the Image in this folder
C:\Downloads

## Download the Linux Image from here
http://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.vhd.zip

## install Azure Stack modules
Install-Module -Name AzureRm.BootStrapper
Use-AzureRmProfile -Profile 2017-03-09-profile -Force
Install-Module -Name AzureStack -RequiredVersion 1.2.10


## download and extract the Azure Stack tools
Set-Location -Path 'C:\'
Invoke-WebRequest -Uri https://github.com/Azure/AzureStack-Tools/archive/master.zip `
    -OutFile master.zip
Expand-Archive -Path .\master.zip -DestinationPath . -Force
Set-Location -Path C:\AzureStack-Tools-master


## import the Azure Stack Connect and ComputeAdmin module
Import-Module .\Connect\AzureStack.Connect.psm1
Import-Module .\ComputeAdmin\AzureStack.ComputeAdmin.psm1


## create the Azure Stack cloud operator environment
Add-AzureRMEnvironment `
  -Name "AzureStackAdmin" `
  -ArmEndpoint "https://adminmanagement.local.azurestack.external"

Set-AzureRmEnvironment `
	-Name 'AzureStackAdmin' `
	-GraphAudience 'https://graph.local.azurestack.external/' `
	-EnableAdfsAuthentication:$true


## retrieve the GUID value of the Azure Stack tenant (ADFS)
$TenantID = Get-AzsDirectoryTenantId `
  -ADFS `
  -EnvironmentName AzureStackAdmin


## sign in to Azure Stack
$adminUserName = 'AzureStackAdmin@azurestack.local'
$adminPassword = '<your Password>' | ConvertTo-SecureString -Force -AsPlainText
$adminCredentials = New-Object PSCredential($adminUserName,$adminPassword)

Login-AzureRmAccount -EnvironmentName 'AzureStackAdmin' `
        		-TenantId $tenantID `
 		     	-Credential $adminCredentials


##Add the Linux Image to the Marketplae
$vhdPath = "C:\Downloads\<name of the VHD file downloaded above>"

Add-AzsVMImage `
  -publisher 'Canonical' `
  -offer 'UbuntuServer' `
  -sku '16.04-LTS' `
  -version '1.0.0' `
  -osType Linux `
  -osDiskLocalPath $vhdPath

  ## Wait 60 to 90 Minutes

  ## END
