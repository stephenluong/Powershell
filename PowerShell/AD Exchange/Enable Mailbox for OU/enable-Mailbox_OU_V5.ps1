﻿
# MUST be ran in EMS

$Filelocation = "C:\Lab 1\departments_noLEGAL or EXEC.csv"

Write-Verbose "Importing OU CSV..."

$existCount=0

# Removing a single line from CSV by importing and exporting - FUTURE VERSIONS
#import-csv "$env:USERPROFILE\desktop\csv.csv" |
#where name -NotLike "*jones*" |
#export-csv "$env:USERPROFILE\desktop\nojones.csv" -NoTypeInformation


#Importing CSV and selecting specific properties
$OU = (Import-Csv $Filelocation -ErrorAction Stop | Select-Object -Property Name,DisplayName,Path)



# Verifying contents of csv --------------------------------------------------
$Remove_CSV = @{}

foreach($item in $OU){
    $x = $item.name
    $exists = Get-mailbox -organizationalunit $x 
    if ($exists -ne $null)
    {
        Write-host "$x has a mailbox" -ForegroundColor Red
        $Remove_CSV.Add('Name',$x)
        #$OUExist = $x
        $existCount++
    }
    else
    {
        Write-Host "$x OU has no mailboxes" -ForegroundColor Green
    }
}

# Removing lines with existing mailboxes then changing variables for file location and OU
if ($existCount -gt 0)
{
    $flag = Read-Host "$existCount Mailboxes already have accounts. Remove them? (Y/N)"
    if ($flag.toupper() -eq 'N'){
        'Exiting Script...'
        exit
    }
    else
    {
        Import-Csv $Filelocation |
        Where-Object{
            foreach ($remove in $remove_CSV.GetEnumerator()) {
                if ($remove.value -contains $_.($remove.name)) {
                    $exists = Get-mailbox -OrganizationalUnit $_.($remove.name) 
                    if ($exists -ne $null)
                    {
                        Write-host "Removing row: OU=$($_.Name),$($_.path)"
                    }
                    return $false
                }
            }
            return $true
        } | Export-Csv 'C:\Users\tlee37\Desktop\output_V2.csv' -NoTypeInformation -Encoding UTF8
    }
}
if ($existCount -gt 0){
    $Filelocation = 'C:\Users\tlee37\Desktop\output_V2.csv'
    Write-Host "New file location at $Filelocation" -ForegroundColor Cyan
    $OU = (Import-Csv $Filelocation -ErrorAction Stop | Select-Object -Property Name,DisplayName,Path)
    $existCount = 0
}

# Execution ------------------------------------------------------------------
# SELECT ALL necessary properties. Piping is optional. 
# Can also add other OUs by piping too ex. Import-Csv $Filelocation -ErrorAction Stop | New-ADOrganizationalOU "OU=departments,DC=enron,DC=com" 
$Database = Read-Host "Specify the database to Store User Mailboxes:"

#Testing additonal error handling
$ErrorCount = 0
$SuccessCount = 0


if ($existCount -gt 0)
{
    $flag = Read-Host "$existCount Mailboxes already have accounts, please remove them. Continue Anyways? (Y/N)"
    if ($flag.toupper() -eq 'N'){
        'Bye'
        exit
    }
    else
    {
        # EXECUTION
        Write-Host "Continuing Enable"
        # Looping to enable mailboxes for each OU in CSV
        $OU.ForEach({
        $Name = $_.Name
        $DN = $_.Path
        $DisplayName = $_.'Display Name'
        try{
            Write-Host "`n[Enable Mailbox]`n Department: $Name`n Database: $Database" -ForegroundColor Cyan
            Get-User -OrganizationalUnit $Name | Enable-mailbox -Database $Database
            $SuccessCount++
        }
        catch
        {
            Write-Host "Error enabling mailboxes for OU: $Name" -ForegroundColor Red
            $ErrorCount++
        }
        finally
        {
            Sleep 1
            $totalCount = $ErrorCount + $SuccessCount
            Write-Verbose "Total OU enable mailbox errors: $totalCount"

            $Percent = (($totalCount/$OU.Count)* 100)
            Write-Progress -Activity "Running Script..." -Status "Completion Progress: $Percent%" -PercentComplete $Percent -CurrentOperation "$($Name)"
        }
    })
    }
}
else
{
    # EXECUTION
    # Looping to enable mailboxes for each OU in CSV
    $OU.ForEach({
        $Name = $_.Name
        $DN = $_.Path
        $DisplayName = $_.'Display Name'
        try{
            Write-Host "---------------------------------------------------------------------------------" -ForegroundColor Cyan
            Write-Host "[Enable Mailbox]`n Department: $Name`n Database: $Database" -ForegroundColor Cyan
            Get-User -OrganizationalUnit $Name | Enable-mailbox -Database $Database -whatif
            $SuccessCount++
        }
        catch
        {
            Write-Host "Error enabling mailboxes for OU: $Name" -ForegroundColor Red
            $ErrorCount++
        }
        finally
        {
            Sleep 1
            $totalCount = $ErrorCount + $SuccessCount
            Write-Verbose "Total OU enable mailbox errors: $totalCount"

            $Percent = (($totalCount/$OU.Count)* 100)
            Write-Progress -Activity "Running Script..." -Status "Completion Progress: $Percent%" -PercentComplete $Percent -CurrentOperation "$($Name)"
        }
    })
}

