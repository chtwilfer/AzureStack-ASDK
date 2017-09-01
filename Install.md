# AzureStack-SingleNode with ASDK in ADFS Mode
Installation on a Azure Virtual Machine (E16s v3)

This repository is for the automatic deployment of a virtual machine (E16s v3) in Azure. Also installed are various Festures. ASDK is downloaded, some files and folders are stored locally on C: \. Then start the installation of AzureStack (nested Virtualization) ....

# Step 1:
Das Powershellscript "Deploy_Azure_Virtual_Machine.ps1" erstellt automatisch unter Angabe von diversen Paramtern eine virtuelle Maschine in der Größe E16 v3.
Folgende Paramter werden bei Start des Scripts abgefragt:

 - ResourceGroup, 
 - Location, 
 - SubscriptionID, 
 - VirtualMachineName, 
 - StorageAccountName,
 - DNSNameVirtualMachine

Ebenso werden dieser Maschine 4 weitere HDDs mit je 180 GB hinzugefügt. Die HDDs liegen im gleichen Storageaccount, wie die OS Disk.
Die OS Disk wird von 127 GB (Standard) auf 256 GB vergrößert.
Installiert wird ein Datacenter Image von Windows Server 2016.

Nach dem Fertigstellen der Imageinstallation müssen noch diverse Fetures installiert werden. Das geschieht mit Powerrshellscript "Install_Features_on_Virtual_Machine.ps1"

# Step 2:
Ein zusätzliches Netzlaufwerk wird der virtuellen Maschine angefügt. In diesem Laufwerk liegen die aktuellen Installationsdateien und -ordner, die für die Installation von Azure Stack erforderlich sind. Diese werden mit dem Ausführen des Scipts "Deploy_Azure_Stack.ps1" an die passende Stelle kopiert. Ebneso werden weitere Einstellungen an der virtuellen Maschine vorgenommen. Zum Schluss startet dann die eigentliche AzureStack Installation.

HAPPY TESTING!!!!

