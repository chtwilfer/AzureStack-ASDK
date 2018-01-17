# Manage Azure Stack via the Privileged Endpoint

In this exercise, you establish a PowerShell Remoting session to the privileged endpoint and run Windows PowerShell cmdlets accessible via the Remoting session. The exercise consists of the following tasks:

1. Create a log share
2. Connect to the privileged endpoint 
3. Manage Azure Stack Admin Cloud accounts via the privileged endpoint.
4. Manage Azure Stack diagnostics log collection via the privileged endpoint.

 

# Task 1: Create a log share

1. Open an RDP session to the AzS-HOST machine by launching the RDP client (mstsc.exe) and connecting with the following parameters:
	Computer: azs-host.azurestack.local
	Username: AzureStackAdmin
	Password: Pa55w.rd
2. From the RDP session to AzS-HOST, start File Explorer.
3. In File Explorer, create a new folder C:\Logs.
4. Right-click Logs and, in the right-click menu, click Properties.
5. In the Logs Properties window, click the Sharing tab and then click Advanced Sharing.
6. In the Advanced Sharing dialog box, click Share this folder and then click Permissions.
7. In the Permissions for Logs window, ensure that the Everyone entry is selected and then click Remove.
8. Click Add, in the Select Users, Computers, Service Accounts, or Groups dialog box, type AzureStackAdmin and click OK.
9. Ensure that the AzureStackAdmin entry is selected and click the Full Control checkbox in the Allow column.
10. Click OK.
11. Back in the Advanced Sharing dialog box, click OK.
12. Back in the Logs Properties window, click Close.
 

# Task 2: Connect to the privileged endpoint

1. Open an RDP session to the AzS-HOST machine by launching the RDP client (mstsc.exe) and connecting with the following parameters:
	Computer: azs-host.azurestack.local
	Username: AzureStackAdmin
	Password: Pa55w.rd
2. From the RDP session to AzS-HOST, start Windows PowerShell ISE as administrator.
3. From the Administrator: Windows PowerShell ISE window, run the following to identify the IP address of the infrastructure VM running the privileged endpoint:

$ipAddress = (Resolve-DnsName –Name AzS-ERCS01).IPAddress
From the Administrator: Windows PowerShell ISE window, run the following to add the IP address of the infrastructure VM running the privileged endpoint to the list of WinRM trusted hosts (unless all hosts are already allowed):
$trustedHosts = (Get-Item –Path WSMan:\localhost\Client\TrustedHosts).Value
If ($trustedHosts –ne ‘*’) {
            If ($trustedHosts –ne ‘’) {
                        $trustedHosts += “,ipAddress”
            } else {
            $trustedHosts = “$ipAddress”
            }
}
Set-Item WSMan:\localhost\Client\TrustedHosts –Value $TrustedHosts -Force

4. From the Administrator: Windows PowerShell ISE window, run the following to store the Azure Stack admin credentials in a variable:

$adminUserName = ‘AzureStackAdmin@azurestack.local’
$adminPassword = ‘Pa55w.rd’ | ConvertTo-SecureString –Force –AsPlainText
$adminCredentials = New-Object PSCredential($adminUserName,$adminPassword)

5. From the Administrator: Windows PowerShell ISE window, run the following to establish a PowerShell Remoting session to the privileged endpoint:

Enter-PSSession –ComputerName $ipAddress –ConfigurationName –PrivilegedEndpoint –Credential $adminCredentials

Verify that the PowerShell Remoting session has been successfully established. The console pane in the Windows PowerShell ISE window should be displaying the prompt starting with the name of the infrastructure VM running the privileged endpoint enclosed in square brackets ([AzS-ERCS01]).
 

# Task 3: Manage Azure Stack Admin Cloud accounts via the privileged endpoint.

1. From the PowerShell Remoting session in the Administrator: Windows PowerShell ISE window, in the console pane, run the following to identify all available PowerShell cmdlets:

Get-Command

2. From the PowerShell Remoting session, run the following to identify current Cloud Admin user accounts:

Get-CloudAdminUserList
 
The list should include only two accounts – your AzureStackAdmin account and the CloudAdmin account.

3. From the PowerShell Remoting session, run the following to change the password of the CloudAdmin account

Set-CloudAdminUserPassword –UserName CloudAdmin

When prompted, in the Windows PowerShell ISE – Input dialog box, in the Current password text box, type Pa55w.rd and click OK. 
When prompted, in the Windows PowerShell ISE – Input dialog box, in the New password text box, type Pa55w.rd1234 and click OK. 
When prompted, in the Windows PowerShell ISE – Input dialog box, in the Repeat password text box, type Pa55w.rd1234 and click OK.
 

# Task 4: Manage Azure Stack diagnostics log collection via the privileged endpoint.

1. From the PowerShell Remoting session in the Administrator: Windows PowerShell ISE window, in the console pane, run the following to collect Azure Stack storage logs:

Get-AzureStackLog –OutputSharePath ‘\\AzS-Host\Logs’ –OutputShareCredential $using:adminCredentials –FilterByRole Storage

You have the option of filtering by role as well as specify the time window for which logs should be collected. For details, refer to https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-diagnostics

Wait until the cmdlet completes and, in File Explorer, review the content of the C:\Logs folder
From the PowerShell Remoting session, run the following to exit the session:

Exit-PSSession
