## How to shutdown and start an Azure Stack system

# Christian Twilfer
# 01.02.2018


# Connect to the Privileged Endpoint via PowerShell Remoting

$Pep = 'azs-ercs01'
$cred = Get-Credential -UserName 'azurestack\cloudadmin' -Message 'Enter CloudAdmin Password'
enter-pssession -computer $Pep -ConfigurationName PrivilegedEndpoint -Credential $cred

# to Stop AzureStack
Stop-AzureStack

# to check Status
Get-ActionStatus Stop-AzureStack

# to Start AzureStack
Start-AzureStack

# to check Status
Get-ActionStatus Start-AzureStack

# to Test AzureStack
Test-AzureStack

Exit-pssession
