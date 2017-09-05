<#
 .SYNOPSIS
    Starts the virtual Machine after a Reboot or Shutdown.
 .DESCRIPTION
    
    Virtual Mchine in Azure have to be started. After that the Dc01 wil be started.
    

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    05.09.2017 
  Purpose/Change:   Initial script development

#>

# Start the Domain Controller automaticlly with the Azure Virtual Machine

# Starts the other virtual Machines
Start-ClusterResource -Name "Virtual Machine AzS-BGPNAT01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-NC01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-SLB01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-Gwy01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-Sql01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-ADFS01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-CA01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-ACS01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-WASP01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-Xrp01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-WAS01" -Verbose
Start-Sleep -Seconds 60 -Verbose
Start-ClusterResource -Name "Virtual Machine AzS-ERCS01" –Verbose
