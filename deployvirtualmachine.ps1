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

param(
    [Parameter(Mandatory = $True)]
    [string] $DeploymentParameters

    $ResourceGroupName
    $VirtualNetworkName
    $DataDiskSizeGB
    


)

$TemplateFilePath = (Get-AutomationVariable -Name 'MRAutomationJSONUri') + '//azuredeploy.json'

$ErrorActionPreference = "Stop"

# Logging in to Azure
$Cred = Get-AutomationPSCredential -Name "AutomationAccount"
Select-MRAzureSubscription -Credential $Cred -SubscriptionId $SubscriptionId
Write-Output "Connected to $SubscriptionId!";

# Select Subscription
Write-Output "Selecting subscription '$SubscriptionId'";
$sub = Select-AzureRmSubscription -SubscriptionId $SubscriptionId
If (!$sub) {
    Throw "Subscription $SubscriptionId not available!"
}

# Step1: (ResourceGroup)

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction $ErrorActionPreference
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}


# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $TemplateFilePathRG;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $TemplateFilePathRG;
}





# Step 1: (VNet)

#NATIPv4Subnet 172.16.0.0/24
#NATIPv4Address 172.16.0.0/24
#NATIPv4DefaultGateway 172.16.0.1

Write-Host "Starting deployment of the VNet...";
if(Test-Path $VNetparametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $TemplateFilePathVNet;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $TemplateFilePathVNet;
}


# Step 1: (virtual Machine)

# Creating a Windows VM Name
$VMType = "AzS_POC_SN"
while($NewVmIsUnique -ne 1) { 
    if (!$VirtualMachineName) {     
        #Generate RandomString for VM 
        $Private:OFS = ""    
        $RandonStringLength = 3    
        $InclChars = '0123456789'    
        $RandomNums = 1..$RandonStringLength | ForEach-Object { Get-Random -Maximum $InclChars.length }   
        $VirtualMachineName = $VMType + [String]$InclChars[$RandomNums] 
    } 
 
    $CheckExistingVM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName -ErrorAction SilentlyContinue
 
 # Test ist VMName exists
     if ($CheckExistingVM) { 
        Write-Output "Machine with generated Identifier already exist! Generating new Identifier..." 
        $VirtualMachineName = null 
        $NewVmIsUnique = 0 
    } 
    else { 
        Write-Output "New Virtual Machine Name is: $VirtualMachineName"
        $NewVmIsUnique = 1 
    } 
}

#fill parameters into a hashtable
$Parameters = @{}
$Parameters.Add("DataDiscSizeGB", $DataDiskSizeGB);
$Parameters.Add("adminUsername", $AdminUsername);
$Parameters.Add("adminPassword", $Secure_String_Pwd);
$Parameters.Add("virtualMachineName", $VirtualMachineName);
$Parameters.Add("virtualNetworkName", $VirtualNetworkName);
$Parameters.Add("subnetName", $SubnetName);
$Parameters.Add("networkSecurityGroupName", $NetworkSecurityGroupName);
# $Parameters.Add("diagnosticsStorageAccountName", $DiagnosticsStorageAccountName);
# $Parameters.Add("Location", $LocationVariable);
$Parameters.Add("VirtualMachineSize", $VirtualMachineSize);

# Start the deployment of the Virtual Machine
Write-Output "Starting deployment...";

$job = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFilePath -TemplateParameterObject $Parameters;

if ($job) {
    write-output "Started deployment: $VirtualMachineName";
}
else {
    Throw "Deployment with $VirtualMachineName could not be started!"
}

return $job

#After deploying the virtual Machine go to Azure Portal and connect per RDP to the Virtual Machine (Öffentliche IP)

# Step 2:
# Expand the OS Disk to 256 GB an add 4 disks a 128 GB

# Step 3:
# Disabel IE Enhanced Security Configuration
function Disable-IEESC
{
$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer
Write-Host “IE Enhanced Security Configuration (ESC) has been disabled.” -ForegroundColor Green
}
Disable-IEESC

# Step 4:
# Rename AdminUser
Rename-LocalUser -Name Florent -NewName Administrator
Logoff
# Logon as "Administrator"

# Step 5:
# Install different Features
Add-WindowsFeature Hyper-V, Failover-Clustering, Web-Server -IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell, RSAT-ADDS -IncludeAllSubFeature
Install-PackageProvider nuget –Verbose
#Reboot the virtual Machine
Restart-Computer
#Logon as "Administrator"
