## Configure Azure Stack infrastructure backup

In this exercise, you will prepare configure Azure Stack infrastructure backup:
1. Create a backup user
2. Create a backup share
3. Generate an encryption key
4. Configure backup controller


# Task 1: Create a backup user
In this task, which you will complete on the AZS-HOST machine, you will:
-       Create a backup user

Open a Remote Desktop (RDP) session to the AZS-HOST machine by launching the RDP client (mstsc.exe) and connecting with the following parameters:
Computer: azs-host.azurestack.local
Username: azurestackadmin
Password: Pa55w.rd

Click Start, in the Start menu, expand the Windows Administrative Tools folder, and click Active Directory Administrative Center.  
In Active Directory Administrative Center, click azurestack (local) and, in the main window pane, click the Users container.
In the Tasks pane, in the Users section, click New and then click User.
In the Create User window, specify the following settings and click OK:
Full name: AzS-BackupOperator
User UPN logon: AzS-BackupOperator@azurestack.local
User SamAccountName logon: azurestack\AzS-BackupOperator
Password: Pa55w.rd
Confirm password: Pa55w.rd
Password options: Password never expires
 

# Task 2: Create a backup share

In this task, you will:
-       Create a backup share. Note that in non-lab scenarios, this share would be external to the Azure Stack deployment. In this lab, for the simplicity sake, you will create it directly on the Azure Stack host.

On the AZS-HOST VM, start File Explorer. 
In File Explorer, create a new folder C:\Backup.
Right-click Backup and, in the right-click menu, click Properties.
In the Backup Properties window, click the Sharing tab and then click Advanced Sharing.
In the Advanced Sharing dialog box, click Share this folder and then click Permissions.
In the Permissions for Backup window, ensure that the Everyone entry is selected and then click Remove.
Click Add, in the Select Users, Computers, Service Accounts, or Groups dialog box, type AzS-BackupOperator and click OK.
Ensure that the AzS-BackupOperator entry is selected and click the Full Control checkbox in the Allow column.
Click Add, in the Select Users, Computers, Service Accounts, or Groups dialog box, click Locations. 
In the Locations dialog box, click the entry representing the local computer (AZS-HOST) and click OK.
In the Enter the object names to select text box, type Administrators and click OK.
Ensure that the Administrators entry is selected and click the Full Control checkbox in the Allow column.
Click OK.
Back in the Advanced Sharing dialog box, click OK.
Back in the Backup Properties window, click the Security tab. 
Click Edit.
In the Permissions for Backup dialog box, Click Add
In the Enter the object names to select text box, type AzS-BackupOperator and click OK.
In the Permissions for AzS-BackupOperator pane, click Full Control in the Allow column and then click OK.
Back in the Backup Properties window, click Close.
Now minimize the Remote Desktop (RDP) window and return the lab VM machine for the remaining steps in this lab.
