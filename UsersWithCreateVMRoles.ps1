# Usage:  This will cycle through all subscriptions and output users that have the role that grants the ability to create VM
# Created by:  Nicholas Zulli
# Creation date:  4.28.2023

Connect-AzAccount

$subscriptions = Get-AzSubscription
$requiredRoleDefinitionNames = @("Virtual Machine Contributor", "Contributor", "Owner")

$allUsers = @()

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id

    foreach ($roleName in $requiredRoleDefinitionNames) {
        $roleDefinition = Get-AzRoleDefinition -Name $roleName
        $roleAssignments = Get-AzRoleAssignment -RoleDefinitionName $roleDefinition.Name | Where-Object {$_.ObjectType -eq 'User'}

        foreach ($roleAssignment in $roleAssignments) {
            $user = Get-AzADUser -ObjectId $roleAssignment.ObjectId
            $userDetails = [PSCustomObject]@{
                DisplayName         = $user.DisplayName
                UserPrincipalName   = $user.UserPrincipalName
                SubscriptionName    = $subscription.Name
                SubscriptionId      = $subscription.Id
                Role                = $roleName
            }

            $allUsers += $userDetails
        }
    }
}

$uniqueUsers = $allUsers | Select-Object -Unique DisplayName, UserPrincipalName

# Generate CSV file name with date and time
$dateTime = Get-Date -Format "yyyy-MM-dd_hh-mm-ss"
$csvFilePath = "c:\temp\VMPermissionsUsers_$dateTime.csv"

# Export to CSV
$uniqueUsers | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "Users with the ability to create VMs across all subscriptions have been exported to $($csvFilePath)"
