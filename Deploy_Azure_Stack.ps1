<#
 .SYNOPSIS
    Deploys an Azure Windows VM with 4 Managed Discs.

 .DESCRIPTION
    The Steps:
    --------------------Script 1 -----------------------
    1. Deploy a ResourceGroup, Windows VM 2016 Datacenter, VNet and NSG
    2. (Expand the OS Disk to 180 GB and) add 4 disks per 180 GB of each disk, set the 4 disk online
    3. disable IE Enhanced Security Configuration
    4. (Rename Admin Username)
    5. (Install different Features)
    ---------------------Scripte 2 ---------------------
    6. integrate Networkshare and copy files and folders
    7. Start ASDK-Installer.ps1
    8. Change file in folder
    9. Start Installation

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    01.09.2017 
  Purpose/Change:   Initial script development

  There are the necessary files and folders on the network share. These are copied according to the script to the C drive
  It is required that in the run-up to the current ASDK is downloaded, unpacked and is uploaded on the share

#>

# Step 6:
# Integrate Networkshare "installshare" and copy files and folders
net use x: \\asdkfiles.file.core.windows.net\installshare  /u:AZURE\asdkfiles 57vSHmJhLvBtZ6J1/WzguHp9gqbpSsAgxU63vxArX6G4Q93meIY0iDXXQTMhCI0GBQq3ukGd2cNXUhW5FzDtvA==


# Step7:
# Start asdk-installer.ps1
cd C:\ASDK-Installer\
.\asdk-installer.ps1
# Reboot the Azure Machine.


# Step 8:
# this Expands diff. files
cd C:\CloudDeployment\Setup
.\BootstrapAzureStackDeployment.ps1


# then change file BareMetal.Tests.ps1 from Host-Folder (D:\) "modified-if necessary" in "C:\CloudDeployment\Roles\PhysicalMachines\Tests"


# Step 9: Start Installation
cd d:\ASDK-Installer
# copy this folder to c:\
# start AzureStack Installation
cd c:\asdk-installer
.\asdk-installer.ps1

# alternative with ADFS
cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -UseADFS -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.5 -NATIPv4DefaultGateway 172.16.0.1 -Verbose

# alternative with Azure Active Directory
cd c:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName [yourdirectory].onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.5 -NATIPv4DefaultGateway 172.16.0.1 -Verbose


<#
########################################if necessary ########################################

# Enable CredSSP - if necessary - change and then rerun .\InstallAzureStackPOC.ps1 -Rerun -Verbose
Enable-WSManCredSSP -Role Server
Set-Item wsman:localhost\client\trustedhosts -Value *
Enable-WSManCredSSP -Role Client -DelegateComputer *
# Open the gpedit.msc console and navigate to Local Computer Policy > Computer Configuration > Administrative Templates > System > Credential Delegation.
# Activate Allow Delegating Fresh Credentials with NTLM-only Server Authentication and add the value WSMAN/*. 


# Change BGBNAT Switch for external Internet  [OPTIONAL]
New-VMSwitch -Name "NATSwitch" -SwitchType Internal -Verbose
$NIC=Get-NetAdapter|Out-GridView -PassThru
New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceIndex $NIC.ifIndex
New-NetNat -Name "NATSwitch" -InternalIPInterfaceAddressPrefix "172.16.0.0/24" -Verbose





# Rerun the Installation
cd C:\CloudDeploment\Setup
.\InstallAzureStackPOC.ps1 -Rerun -Verbose


#>
