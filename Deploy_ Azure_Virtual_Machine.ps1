<#
 .SYNOPSIS

    Deploying of an Azure Windows VM with 4 Data Discs.


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

    This Powershellscript (Script 1) deployes:
    1. a ResourceGroup
    2. a VNet
    3. a Public IP-Address
    4. a Storage Account
    5. a Virtual Machine
    6. 4 Data Disk in the Storage Account
    7. (Rezise OS Disk to 180 GB)
    8. Starts the Virtual Machine


 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]

  Creation Date:    01.09.2017 
  Purpose/Change:   


  .PARAMETERS
  ResourceGroup
  The Name of the ResourceGroup you want to be created

  Location
  The Location you want to be created

  SubscriptionID
  Your SubscriptionID for Deployment

  VirtualMachineName
  The Name of the virtual Machine

  StorageAccountName
  write in lower caes

  Virtual Machine DNS Name
  write in lower case

#>

param (

    [Parameter(Mandatory=$True)]
    [string] $ResourceGroup,
    
    [Parameter(Mandatory=$True)]
    [string] $Location,

    [Parameter(Mandatory=$True)]
    [string] $SubscriptionID,

    [Parameter(Mandatory=$True)]
    [string] $VirtualMachineName,    

    [Parameter(Mandatory=$True)]
    [string] $StorageAccountName,
    
    [Parameter(Mandatory=$True)]
    [string] $DNSNameVirtualMachine  


)

#Create a Resource Group, VNet, Virtual Machine

#Variables
# Set variables resource group
$rgName                = $ResourceGroup
$location              = $Location


# Set variables for VNet
$vnetName              = "$VirtualMachineName-VNet"
$vnetPrefix            = "172.16.0.0/24"
$subnetName            = "$VirtualMachineName-Subnet"
$subnetPrefix          = "172.16.0.0/24"

# Set variables for storage
$stdStorageAccountName = $StorageAccountName

# Set variables for VM
$vmSize                = "Standard_E16s_v3"
$newOSDiskSize         = "180"
$publisher             = "MicrosoftWindowsServer"
$offer                 = "WindowsServer"
$sku                   = "2016-Datacenter"
$version               = "latest"
$vmName                = $VirtualMachineName
$osDiskName            = "$VirtualMachineName-OS"
$nicName               = "$VirtualMachineName-NIC"
$privateIPAddress      = "172.16.0.4"
$pipName               = "$VirtualMachineName-PIP"
$dnsName               = $DNSNameVirtualMachine

Write-Output $vmName
Write-Output $osDiskName


#Login to Azure and select subscription
Write-Output "Login to Azure"
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionID $SubscriptionID


#Create Resource Group
New-AzureRmResourceGroup -Name $rgName -Location $location
Write-Output "ResourceGroup $rgName created"


#Create VNEt with Subnet
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName -AddressPrefix $vnetPrefix -Location $location
Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix $subnetPrefix
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
Write-Output "VNet $vnetName created"


#Create Public IP-Address
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rgName -AllocationMethod Static -DomainNameLabel $dnsName -Location $location
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Subnet $subnet -Location $location -PrivateIpAddress $privateIPAddress -PublicIpAddress $pip
Write-Output "Network card $nicName created"
Write-Output "PublihcIP $pipName created"
Write-Output "DNS $dnsName created"


#Create StorageAccount
$stdStorageAccount = New-AzureRmStorageAccount -Name $stdStorageAccountName -ResourceGroupName $rgName -Type Standard_LRS -Location $location
Write-Output "Storage account $stdStorageAccountName created"


#Create the Virtual Machine
#Get-Credential = Windows-Username and Password
Write-Output "Creating the virtual machine"
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
Write-Output "Specify user name and password for the virtual machine"
$cred = Get-Credential 
$vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version $version
$osVhdUri = $stdStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $osDiskName + ".vhd"
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $osDiskName -VhdUri $osVhdUri -CreateOption fromImage
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id -Primary
New-AzureRmVM -VM $vmConfig -ResourceGroupName $rgName -Location $location
Write-Output "Virtual machine created"


#Stops the Virtual Machine
Write-Output "Virtual machine shutdown"
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName


#Add Data Disks - Suggest only adding same caching type at once and setup in Windows to avoid confusion 
#Specify your Storage account name
Write-Output "Creating 4 data disk and added it to the virtual machine"
$saName = $stdStorageAccountName
#This pulls your storage account info for use later 
$storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $saName 
#Pulls the VM info for later 
$vmdiskadd=Get-AzurermVM -ResourceGroupName $rgname -Name $vmname 
#Sets the URL string for where to store your vhd files - converts to https://azspoc01storage.blob.core.windows.net/vhds
#Also adds the VM name to the beginning of the file name 
$DataDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 180 -Name $vmName-Data1 -VhdUri $DataDiskUri-Data1.vhd -VM $vmdiskadd -Caching ReadWrite -lun 0 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 180 -Name $vmName-Data2 -VhdUri $DataDiskUri-Data2.vhd -VM $vmdiskadd -Caching ReadWrite -lun 1 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 180 -Name $vmName-Data3 -VhdUri $DataDiskUri-Data3.vhd -VM $vmdiskadd -Caching ReadWrite -lun 2 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 180 -Name $vmName-Data4 -VhdUri $DataDiskUri-Data4.vhd -VM $vmdiskadd -Caching ReadWrite -lun 3 
#Updates the VM with the disk config - does not require a reboot 
Update-AzureRmVM -ResourceGroupName $rgname -VM $vmdiskadd

<#
#Rezises the OS Disk from 127GB to 180GB ($newOSDiskSize)
Write-Output "Rezise the os disk to 180 GB"
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
$vm.StorageProfile.OSDisk.DiskSizeGB = $newOSDiskSize
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm
Write-Output "OS Disk is now 180 GB"
#>

#Starts the Virtual Machine
Write-Output "Virtual machine starting"
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName


# Wait for 5 Minutes
Write-Output "Wait 5 minutes for virtual machine starting"
Start-Sleep -s 300


#End of Deployment
Write-Output "Deployment has finished!!!"
