Import-Module Az
$rootPath = "C:\Users\pwood\OneDrive - Kforce, Inc\1-AZDevOps\RPA\BluePrism.IaC\sandbox"
$scriptsPath = "$rootPath\scripts"
cd $scriptsPath
. ./bpLabCommon.ps1
. ./bpLabLogins.ps1

Logout-AzAccount
Login-KforceLab_BPSbx

# Provide parameter values
$subscription = "KFORCE_LABS"
$resourceGroup = $bpLabRGName

$configName = $prefixStr3 # The name of the deployment, i.e. BaseConfig01. Do not use spaces or special characters other than _ or -. Used to concatenate resource names for the deployment.
$domainName = $bpDomainName # The FQDN of the new AD domain.
$serverOS = "Windows Server 2016" # The OS of server VMs in your deployment, i.e. Windows Server 2016 or Windows Server 2012 R2.
$clientOS = "Windows 10" # The OS of client VMs in your deployment, i.e. Windows Server 2016 or Windows 10.
$adminUserName = $bpLabVMAdminUser # The name of the domain administrator account to create, i.e. globaladmin.
$adminPassword = (Get-AzKeyVaultSecret -vaultName $bpLabVaultName -name "vmAdminPassword").SecretValueText  # The administrator account password.
$vmSize = "Standard_DS2_v2" # Select a VM size for all server VMs in your deployment.
$vmDCSize = "Standard_A2_v2" #Select a VM size for Domain Controller VM in your deployment
$vmClientSize = "Standard_A2_v2" #Select a VM size for CLIENT VMs in your deployment
$vmAppSize = "Standard_DS2_v2" #Select a VM size for APP/SQL VMs in your deployment
$dnsLabelPrefix = $prefixStr3 # DNS label prefix for public IPs. Must be lowercase and match the regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.
$_artifactsLocation = "https://raw.githubusercontent.com/pwconsultant/TLG/master/tlg-base-config_3-vm.m365-ems"#"https://raw.githubusercontent.com/maxskunkworks/tlg/master/tlg-base-config_3-vm.m365-ems" # Location of template artifacts.
$_artifactsLocationSasToken = "" # Enter SAS token here if needed.
$templateUri = "$_artifactsLocation/azuredeploy.json"

# Add parameters to array
$parameters = @{}
$parameters.Add("configName",$configName)
$parameters.Add("domainName",$domainName)
$parameters.Add("serverOS",$serverOS)
$parameters.Add("clientOS",$clientOS)
$parameters.Add("adminUserName",$adminUserName)
$parameters.Add("adminPassword",$adminPassword)
$parameters.Add("vmSize",$vmSize)
$parameters.Add("dnsLabelPrefix",$dnsLabelPrefix)
$parameters.Add("_artifactsLocation",$_artifactsLocation)
$parameters.Add("_artifactsLocationSasToken",$_artifactsLocationSasToken)

# Log in to Azure subscription
Select-AzSubscription -SubscriptionName $subscription

# Deploy resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Deploy template
New-AzResourceGroupDeployment -name $configName -ResourceGroupName $resourceGroup `
  -TemplateUri $templateUri -TemplateParameterObject $parameters -DeploymentDebugLogLevel All