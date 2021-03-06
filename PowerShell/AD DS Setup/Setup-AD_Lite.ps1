<# 
TODO Will test this script to see if it works with reboot_run
#>

Install-WindowsFeature –Name AD-Domain-Services, RSAT-ADDS-Tools-IncludeManagementTools 
Import-Module ADDSdeployment 
Install-ADDSForest `
    –DomainName enron.com `
    –SafeModeAdministratorPassword (ConvertTo-SecureString Password1 –AsPlainText –Force) `
    –DomainMode WinThreshold `
    –DomainNetbiosname ENRON  `
    –ForestMode WinThreshold `
    -InstallDNS `
    -Confirm:$False

Restart-Computer -Confirm

<# 
Import-Module ADDSDeployment
# AD DS installation
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetBios `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $DSRM `
    -Force:$true
# Will be Prompted for DSRM recovery password, must set -NoRebootOnCompletion to $false
# May require a COMPLEX password
Restart-Computer #>

Install-WindowsFeature AD-Domain-Services, RSAT-ADDS-Tools
Install-ADDSForest –DomainName ENRON.COM –SafeModeAdministratorPassword (ConvertToSecureString Password1 –AsPlainText –Force) –DomainMode WinThreshold –
DomainNetbiosname ENRON –ForestMode WinThreshold -InstallDNS -Confirm:$False