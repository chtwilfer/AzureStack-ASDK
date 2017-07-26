<#
 .SYNOPSIS
    Deploys an Azure Windows VM with 4 Managed Discs.

 .DESCRIPTION
    The Steps:
    1. Deploy a ResourceGroup, Windows VM 2016 Datacenter, VNet and NSG
    2. Expand the OS Disk to 256 GB and add 4 disks per 128 GB of each disk, set the 4 disk online
    3. disable IE Enhanced Security Configuration
    4. Rename Admin Username
    5. Install different Features
    6. Download ASDK and extract
    7. Copy Files and Ordner to C:\
    8. Enable CredSSP
    9. Change some settings in the BareMetal.Tests.ps1
    10. Change T-Shirt Size of the Virtual Machine
    11. Install POC
    12. Change BGBNAT Switch for external Internet Access
    13. Rerun the InstallScript

 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]
  Creation Date:    23.07.2017 
  Purpose/Change:   Initial script development
#>

# Step 6:
# Download ASDK and extract
# https://azure.microsoft.com/en-us/overview/azure-stack/development-kit/
# Exstract the File to C:\ASDK
    
# Step 7: 
# Copy Files and Ordner to C:\
# When extracted, mount the disk CloudBuilder.vhdx and copy folders CloudDeployment, fwupdate and tools in the root of your C drive. You can eject the disk CloudBuilder.

# Step 8:
# Enable CredSSP
Enable-WSManCredSSP -Role Server
Set-Item wsman:localhost\client\trustedhosts -Value *
Enable-WSManCredSSP -Role Client -DelegateComputer *
# Open the gpedit.msc console and navigate to Local Computer Policy > Computer Configuration > Administrative Templates > System > Credential Delegation.
# Activate Allow Delegating Fresh Credentials with NTLM-only Server Authentication and add the value WSMAN/*. 

# Step 9:
# Change some settings in the BareMetal.Tests.ps1
# C:\CloudDeployment\Roles\PhysicalMachines\Tests\BareMetal.Tests.ps1 and to find $isVirtualizedDeployment. This variable is present 3 times in the file.
# Remove the -not before each variable
# Change also at Line XXXXXX $false to $true

# Step 10:  
# Change T-Shirt Size of the Virtula Machine
# Change the T-Shirt Size within the Azure Portal to E16sv3

cls
#Login-AzureRmAccount

# Variables
$ResourceGroupName = "ResGroup"
$VMName = "vmname"
#$VMSize = "Standard_A3"
$VMSize = "Standard_A1"
$starttime = get-date -format hh:mm:ss
Write-host "Starting resize at " $starttime

# Shut down VM
# VM must be shut down before size change to switch between A/D/DS/Dv2/G/GS/N

Stop-AzureRmVm -name $VMName -ResourceGroupName $ResourceGroupName -StayProvisioned -Force

# Resize VM 
$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName
$vm.HardwareProfile.VirtualMachineSize = $VMSize
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $vm

$endtime = get-date -format hh:mm:ss
$time = New-TimeSpan -Start $starttime -End $endtime
write-host "Resize finished. Time to complete: " $time.minutes"minute(s) and "$time.seconds "seconds."

# Start VM

Start-AzureRmVm -name $VMName -ResourceGroupName $ResourceGroupName



# Step 11:
# Install POC
cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName yourdirectory.onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.2 -NATIPv4DefaultGateway 172.16.0.1 -Verbose

# Step 12:
# Change BGBNAT Switch for external Internet Access
New-VMSwitch -Name "NATSwitch" -SwitchType Internal -Verbose
$NIC=Get-NetAdapter|Out-GridView -PassThru
New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceIndex $NIC.ifIndex
New-NetNat -Name "NATSwitch" -InternalIPInterfaceAddressPrefix "172.16.0.0/24" –Verbose

# Step 13:
.\InstallAzureStackPOC.ps1 -Rerun -Verbose
