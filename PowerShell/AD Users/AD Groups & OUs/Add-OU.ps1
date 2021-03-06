<# 
~ Script to add multiple OUs

@ NOTE: remember to add parent OUs at the very top
#>

$FileLocation = ""

$OUPath = Import-Csv $FileLocation

foreach ($item in $OUPath) {
    $CheckOU = [adsi]::Exists("LDAP://$($item.Path)")
    if ($CheckOU -eq $true) {
        Write-Host "$($item.Name) already exists. Skipping." -ForegroundColor DarkMagenta
    }else {
        New-ADOrganizationalUnit `
            -Name $item.Name `
            -DisplayName $item.Displayname `
            -Path $item.path `
            -ProtectedfromAccidentalDeletion $false `
            -Verbose
    }
}

#New-ADOrganizationalUnit -Name "UserAccounts" -Path "DC=ENRON,DC=COM"