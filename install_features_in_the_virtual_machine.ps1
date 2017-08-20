<#
 .SYNOPSIS

    Deploying AzureStack of an Azure Windows VM with 4 Data Discs.


 .DESCRIPTION

    This Powersahellscript installs needed Features und rename the Administrator Name.

    

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]

  Creation Date:    16.08.2017 
  Purpose/Change:   

#>

Add-WindowsFeature Hyper-V, Failover-Clustering, Web-Server -IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell, RSAT-ADDS -IncludeAllSubFeature
Install-PackageProvider nuget –Verbose

Rename-LocalUser -Name ctadmin -NewName Administrator
Logoff

#Logon as "Administrator"

Restart-Computer
