# Install the AzureRM.Bootstrapper module, set the profile, and install AzureRM and AzureStack modules
Install-Module -Name AzureRm.BootStrapper -Force
Use-AzureRmProfile -Profile 2017-03-09-profile
Install-Module -Name AzureStack -RequiredVersion 1.2.11 -Force

# Use the NetBIOS name for the Azure Stack domain. On ASDK, the default is AzureStack
$domain = "AzureStack"
# Point to the directory where the RP installation files were extracted
$tempDir = 'D:\AzureStack\AzureStackMySQLPlattform'

# The service admin account (can be AAD or ADFS)
$serviceAdmin = "user@abcdefg.onmicrosoft.com"
$AdminPass = ConvertTo-SecureString "Password" -AsPlainText -Force
$AdminCreds = New-Object System.Management.Automation.PSCredential ($serviceAdmin, $AdminPass)

# Set the credentials for the Resource Provider VM
$vmLocalAdminPass = ConvertTo-SecureString "Password" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin", $vmLocalAdminPass)

# and the cloudadmin credential required for Privileged Endpoint access
$CloudAdminPass = ConvertTo-SecureString "Password" -AsPlainText -Force
$CloudAdminCreds = New-Object System.Management.Automation.PSCredential ("$domain\azurestackadmin", $CloudAdminPass)

# change the following as appropriate
$PfxPass = ConvertTo-SecureString "Password" -AsPlainText -Force

# Change directory to the folder where you extracted the installation files
# and adjust the endpoints
.$tempDir\DeployMySQLProvider.ps1 -AzCredential $AdminCreds -VMLocalCredential $vmLocalAdminCreds -CloudAdminCredential $CloudAdminCreds -PrivilegedEndpoint '192.168.200.225' -DefaultSSLCertificatePassword $PfxPass -DependencyFilesLocalPath $tempDir\cert
