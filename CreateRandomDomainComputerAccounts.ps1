################################################
# This script will create random computer names at the quantity listed below.  It will move to a designated OU as you define.
# Then it will query the domain users and randomly assign a user to the computer via the description field.
################################################
# Created By:  Nicholas Zulli
# Created On:  20240703
################################################

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the number of computers to create for each prefix
# WS = Workstation (local) / LT = Laptop (remote)
$wsQuantity = 24
$ltQuantity = 68

# Define OU names
$ouRemoteName = "Computers-Remote"
$ouLocalName = "Computers-Local"

# Define the distinguished names for the OUs
$ouRemote = "OU=$ouRemoteName,DC=ld,DC=local"
$ouLocal = "OU=$ouLocalName,DC=ld,DC=local"

# Function to generate a random alphanumeric string of a specific length
function Generate-RandomString {
    param (
        [int]$length
    )
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $random = -join ((1..$length | ForEach-Object { $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)] }))
    return $random
}

# Function to create a computer object
function Create-Computer {
    param (
        [string]$computerName,
        [string]$ouPath,
        [string]$assignedUser
    )
    # Check if the computer already exists
    $computerExists = Get-ADComputer -Filter { Name -eq $computerName } -ErrorAction SilentlyContinue

    if (!$computerExists) {
        # Create the computer object
        New-ADComputer -Name $computerName -Path $ouPath -OtherAttributes @{'description'="Assigned to $assignedUser"}
        Write-Output "Computer $computerName created in OU $ouPath"
    } else {
        Write-Output "Computer $computerName already exists"
    }
}

# Function to generate a unique computer name
function Generate-UniqueComputerName {
    param (
        [string]$prefix
    )
    do {
        $randomString = Generate-RandomString -length 8
        $computerName = $prefix + $randomString
        $computerExists = Get-ADComputer -Filter { Name -eq $computerName } -ErrorAction SilentlyContinue
    } until (!$computerExists)
    return $computerName
}

# Generate computer names
$computerNames = @()
for ($i = 0; $i -lt $wsQuantity; $i++) {
    $computerNames += Generate-UniqueComputerName -prefix "ws-"
}
for ($i = 0; $i -lt $ltQuantity; $i++) {
    $computerNames += Generate-UniqueComputerName -prefix "lt-"
}

# Check and create OUs if they do not exist
if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouRemote } -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $ouRemoteName -Path "DC=ld,DC=local"
    Write-Output "OU '$ouRemoteName' created"
}

if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouLocal } -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $ouLocalName -Path "DC=ld,DC=local"
    Write-Output "OU '$ouLocalName' created"
}

# Get all domain users
$domainUsers = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName

# Create computers and assign them to OUs
foreach ($computerName in $computerNames) {
    $assignedUser = Get-Random -InputObject $domainUsers
    if ($computerName -like "ws-*") {
        Create-Computer -computerName $computerName -ouPath $ouLocal -assignedUser $assignedUser
    } elseif ($computerName -like "lt-*") {
        Create-Computer -computerName $computerName -ouPath $ouRemote -assignedUser $assignedUser
    }
}

Write-Output "Script execution completed"
