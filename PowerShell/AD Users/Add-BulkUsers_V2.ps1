<# 
Add-BulkUsers_Lite_V2: 

Changes:
	Adjusted for CSVs requiring more details and with more AD property friendly names
	Ex) Previously CSV had firstname, lastname, username, etc. Now we have AD specific Name, GivenName, Surname, samAccount

	Also changed foreach to foreach method, which is more efficient than foreach statement (see v1 for example)
#>

# Import active directory module for running AD cmdlets
Import-Module activedirectory

#@ Adjust where lcation of csv file is
$Filelocation = ""  # Ex) C:\Users\Administrators\desktop\bulk_users.csv
#@ Added onto the UPN (NOT NEEDED)
#$domainName= ""     # Ex)terence.local
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv $Filelocation

#Loop through each row containing user details in the CSV file 
#@ NOTE: Foreach method doesn't work for creating New Groups OR OUs
$ADusers.foreach
({
	#Read user data from each field in each row and assign the data to a variable as below
	$Name 				= $_.Name
	# Change this if not test environment
	$Password 			= "Password1"
	$GivenName 			= $_.GivenName
	$Surname 			= $_.Surname
	$SamAccountName 	= $_.SamAccountName
	$OfficePhone		= $_.OfficePhone
	$Department			= $_.Department
	$Path				= $_.Path
	$UserPrincipalName	= $_.UserPrincipalName
	$Description		= $_.Description

    #Check to see if the user already exists in AD
	if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $SamAccountname already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
			-Name "$Name" `
            -SamAccountName $SamAccountName `
            -UserPrincipalName "$UserPrincipalName" `
            -GivenName $GivenName `
            -Surname $Surname `
            -Enabled $True `
			-OfficePhone $OfficePhone `
			-Department $Department `
			-Path $Path `
			-Description $Description `
			-AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
			-ChangePasswordAtLogon $False
			-Whatif
	}
})
