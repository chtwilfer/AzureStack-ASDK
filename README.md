# AzureStack Development Kit in connected Mode
Installation on a Azure Virtual Machine (E16s v3)

This repository is for the automatic deployment of a virtual machine (E16s v3) in Azure. Also installed are various Festures. ASDK is downloaded, some files and folders are stored locally on C: \. Then start the installation of AzureStack ....

# Step 1:
The Powershellscript "Deploy_Azure_Virtual_Machine.ps1" automatically creates a virtual machine in the size E16 v3, specifying various parameters.
The following parameters are queried when the script is started:

 - ResourceGroup, 
 - Location, 
 - SubscriptionID, 
 - VirtualMachineName, 
 - StorageAccountName,
 - DNSNameVirtualMachine

Also, this machine is added 4 additional HDDs with 180 GB each. The HDDs are in the same storageaccount as the OS disk.
The OS disk is increased from 127 GB (standard) to 256 GB.
A datacenter image of Windows Server 2016 is installed.


After completing the image installation, various features have to be installed. This is done with Powerrshellscript "Install_Features_on_Virtual_Machine.ps1".

# Step 2:
An additional network drive is attached to the virtual machine. This drive contains the current installation files and folders that are required to install AzureStack. These are copied to the appropriate location by running the "Deploy_Azure_Stack.ps1" scripted. Other settings are also made on the virtual machine. Finally, the actual AzureStack installation starts.

# Step 3:
Finishing work after installing AzureStack, such as Password Experation, Resource Provider Registration, Install AuzreStack Powershell Modules, connect to a subscription and download a template, etc. WatchScript: ConfigASDKwithRegistertoAzure.ps1.

# If costs have to be saved
It is also possible to shut down the AzureStack SingleNode POC in Azure for reasons of cost. For that I wrote 2 more scripts. Watch: Shutdown_virt_machines_in_azure.ps1 and Start_virt_maschines_after_Boot.ps1.

The E16s_v3 machine in Azure would cost about $ 1400, as long as it runs 24/7. If you drive it down in the night, you only have to pay for the required storage space.


HAPPY TESTING!!!!

Copyright 2017 - Christian Twilfer
