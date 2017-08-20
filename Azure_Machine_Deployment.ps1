<#
 .SYNOPSIS

    Deploying of an Azure Windows VM with 4 Data Discs.


 .DESCRIPTION

    This Powershellscript deployes:
    1. a ResourceGroup
    2. a VNet
    3. a Public IP-Address
    4. a Storage Account
    5. a Virtual Machine
    6. 4 Data Disk in the Storage Account
    7. Rezise OS Disk to 256 GB
    8. Starts the Virtual Machine


 .NOTES
  Version:          1.0
  Author:           Christian Twilfer (c.twilfer@tec-networks.de]

  Creation Date:    18.08.2017 
  Purpose/Change:   

#>

param (

    [Parameter(Mandatory=$True)]
    [string] $ResourceGroup,
    
    [Parameter(Mandatory=$True)]
    [string] $Location,

    [Parameter(Mandatory=$True)]
    [string] $SubscriptionID,

    [Parameter(Mandatory=$True)]
    [string] $VirtualMachineName    

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
$stdStorageAccountName = "azspocstorage"

# Set variables for VM
$vmSize                = "Standard_E16s_v3"
$newOSDiskSize         = 256
$publisher             = "MicrosoftWindowsServer"
$offer                 = "WindowsServer"
$sku                   = "2016-Datacenter"
$version               = "latest"
$vmName                = $VirtualMachineName
$osDiskName            = "$VirtualMachineName-OS1"
$nicName               = "$VirtualMachineName-NIC"
$privateIPAddress      = "172.16.0.4"
$pipName               = "$VirtualMachineName-PIP"
$dnsName               = $VirtualMachineName

Write-Output $vmName
Write-Output $osDiskName


#Login to Azure and select subscription
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionID $SubscriptionID


#Create Resource Group
New-AzureRmResourceGroup -Name $rgName -Location $location
Write-Output $rgName


#Create VNEt with Subnet
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName -AddressPrefix $vnetPrefix -Location $location
Add-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix $subnetPrefix
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
Write-Output $vnetName


#Create Public IP-Address
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $rgName -AllocationMethod Static -DomainNameLabel $dnsName -Location $location
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Subnet $subnet -Location $location -PrivateIpAddress $privateIPAddress -PublicIpAddress $pip
Write-Output $nicName
Write-Output $pipName
Write-Output $dnsName


#Create StorageAccount
$stdStorageAccount = New-AzureRmStorageAccount -Name $stdStorageAccountName -ResourceGroupName $rgName -Type Standard_LRS -Location $location
Write-Output $stdStorageAccountName


#Create the Virtual Machine
#Get-Credential = Windows-Username and Password 
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$cred = Get-Credential 
$vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $publisher -Offer $offer -Skus $sku -Version $version
$osVhdUri = $stdStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $osDiskName + ".vhd"
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name $osDiskName -VhdUri $osVhdUri -CreateOption fromImage
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id -Primary
New-AzureRmVM -VM $vmConfig -ResourceGroupName $rgName -Location $location


#Stops the Virtual Machine
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName


#Add Data Disks - Suggest only adding same caching type at once and setup in Windows to avoid confusion 
#Specify your Storage account name
$saName = $stdStorageAccountName
#This pulls your storage account info for use later 
$storageAcc=Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $saName 
#Pulls the VM info for later 
$vmdiskadd=Get-AzurermVM -ResourceGroupName $rgname -Name $vmname 
#Sets the URL string for where to store your vhd files - converts to https://azspoc01storage.blob.core.windows.net/vhds
#Also adds the VM name to the beginning of the file name 
$DataDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 128 -Name $vmName-Data1 -VhdUri $DataDiskUri-Data1.vhd -VM $vmdiskadd -Caching ReadWrite -lun 0 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 128 -Name $vmName-Data2 -VhdUri $DataDiskUri-Data2.vhd -VM $vmdiskadd -Caching ReadWrite -lun 1 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 128 -Name $vmName-Data3 -VhdUri $DataDiskUri-Data3.vhd -VM $vmdiskadd -Caching ReadWrite -lun 2 
Add-AzureRmVMDataDisk -CreateOption empty -DiskSizeInGB 128 -Name $vmName-Data4 -VhdUri $DataDiskUri-Data4.vhd -VM $vmdiskadd -Caching ReadWrite -lun 3 
#Updates the VM with the disk config - does not require a reboot 
Update-AzureRmVM -ResourceGroupName $rgname -VM $vmdiskadd


#Rezises the OS Disk from 127GB to 256GB ($newOSDiskSize)
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName
$vm.StorageProfile.OSDisk.DiskSizeGB = $newOSDiskSize
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm


#Starts the Virtual Machine
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName


#End of Deployment
Write-Output "Deployment has finished!!!"
