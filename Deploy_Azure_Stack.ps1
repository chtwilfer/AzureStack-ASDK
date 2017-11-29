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
    6. Download ASDK
    7. Start ASDK-Installer.ps1


 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    01.09.2017 
  Purpose/Change:   Initial script development

  There are the necessary files and folders on the network share. These are copied according to the script to the C drive
  It is required that in the run-up to the current ASDK is downloaded, unpacked and is uploaded on the share

#>

# Step 6:
# Download ASDK from this Link: https://azure.microsoft.com/en-us/overview/azure-stack/development-kit/

# Step 7: Start Installation

# start AzureStack Installation
cd c:\asdk-installer
.\asdk-installer.ps1

# alternative with ADFS
cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -UseADFS -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.5 -NATIPv4DefaultGateway 172.16.0.1 -Verbose

# alternative with Azure Active Directory
cd c:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName [yourdirectory].onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.5 -NATIPv4DefaultGateway 172.16.0.1 -Verbose

# Rerun the Installation
cd C:\CloudDeploment\Setup
.\InstallAzureStackPOC.ps1 -Rerun -Verbose


#>
