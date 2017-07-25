# AzureStack-SingleNode with ASDK
Installation on a Azure Virtual Machine (E16s v2)

This repository is for the automatic deployment of a virtual machine (E16s v2) in Azure. Also installed are various Festures. ASDK is downloaded, some files and folders are stored locally on C: \. Then start the installation of AzureStack (nested Virtualization) ....

# Step 1:
automaticlly create a virtual machine in azure, adds features, ...

# Validate existing deployment templates
You can verify if an existing deployment template is valid for a given environment with the Test-AzureRmResourceGroupDeployment PowerShell cmdlet. After connecting to your environment in a PowerShell session run the following PowerShell cmdlet

Test-AzureRmResourceGroupDeployment -ResourceGroupName ExampleGroup -TemplateFile c:\Templates\azuredeploy.json

Please note that this cmdlet does not verify the resource provider specific properties for the resources within the template. This cmdlet can be used for Microsoft Azure and Microsoft Azure Stack Developmetn Kit.


# Step 2:
download ASDK, extract it an copies some folder to C:\. Changes some entries in the deploymednt scripts. Installs AzureStack


Who has interest in supporting the project?

