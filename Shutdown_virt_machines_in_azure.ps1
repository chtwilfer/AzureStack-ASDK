<#
 .SYNOPSIS
    Shutdown of all virtuell Machines .

 .DESCRIPTION
    All the virtual Machines will be shutdown. The last Machine is the AzS-DC01.
    

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    05.09.2017 
  Purpose/Change:   Initial script development

#>

Stop-VM -Name "AzS-ERCS01" -Force -Verbose
Stop-VM -Name "AzS-WAS01" -Force -Verbose
Stop-VM -Name "AzS-Xrp01" -Force -Verbose
Stop-VM -Name "AzS-WASP01" -Force -Verbose
Stop-VM -Name "AzS-ACS01" -Force -Verbose
Stop-VM -Name "AzS-CA01" -Force -Verbose
Stop-VM -Name "AzS-ADFS01" -Force -Verbose
Stop-VM -Name "AzS-Sql01" -Force -Verbose
Stop-VM -Name "AzS-Gwy01" -Force -Verbose
Stop-VM -Name "AzS-SLB01" -Force -Verbose
Stop-VM -Name "AzS-NC01" -Force -Verbose
Stop-VM -Name "AzS-BGPNAT01" -Force –Verbose

# Wait 5 Minutes for shutdown
Start-Sleep -s 300
Stop-VM -Name "AzS-DC01" -Force -Verbose

# Now the Azure Virtual Machine could be stopped with the Azure Portal
