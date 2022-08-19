<#
Description: Adds or removes a user from a particular Azure AD group
Date: 01st Aug, 2022
#>

# Service-Bus message will be passed as a parameter, string array
param([string] $mySbMsg, $TriggerMetadata)

# abort function
function Abort() {
    Write-Host "Process Terminated - $(Get-Date)"
    throw
}

# checks if executor is authenticated/authorised or not
function ConnectionSetup() {
    # authentication check
    try {
        Write-Verbose "Trying to setup connection.."
        Connect-AzAccount -Identity
        $accessToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token
        Connect-MgGraph -AccessToken $accessToken
    }
    catch {
        Write-Error "$_"
        return $null
    }

    return $true
}

# get the user object id from Azure AD
function GetAdUserID($UserUPN) {
    Write-Verbose "Getting the ObjectId for user UPN: ${UserUPN} .."
    try {
        # getting the user object id from Azure AD
        $UserID = (Get-MgUser -Filter "UserPrincipalName eq '${UserUPN}'").Id
        if (!${UserID}) {
            return $null
        }
    }
    catch {
        Write-Error "$_"
        return $null
    }

    Write-Host "User ObjectId: ${UserID}"
    return ${UserID}
}

# get the group object id from Azure AD
function GetAdGroupID($GroupName) {
    Write-Verbose "Getting the ObjectId for group name: ${GroupName} .."
    try {
        # getting the object id for provided group name
        $GroupID = (Get-MgGroup -Filter "DisplayName eq '${GroupName}'").Id
        if (!${GroupID}) {
            return $null
        }
    }
    catch {
        Write-Error "$_"
        return $null
    }

    Write-Host "Group ObjectId: ${GroupID}"
    return ${GroupID}
}

# adds or removes the user from Azure AD group
function AddDropGroupMember() {
    param($GroupID, $UserID, $AddDrop)
    try {
        Write-Host "Process Details: AD Group - ${GroupName} | User - ${UserUPN} | Operation - ${AddDrop}"
        if (${AddDrop} -eq "Add") {
            # adding the user to the group
            New-MgGroupMember -GroupId ${GroupID} -DirectoryObjectId ${UserID} -ErrorAction Stop
        }
        elseif (${AddDrop} -eq "Drop") {
            # removing the user from the group
            Remove-MgGroupMemberByRef -GroupId ${GroupID} -DirectoryObjectId ${UserID} -ErrorAction Stop
        }
        else {
            Write-Error "ERROR: Invalid group operation specified. Usage: Add/Drop"
            return 1
        }
    }
    catch {
        Write-Error "$_"
        return 1
    }

    return 0
}

# main function call
function main() {
    Write-Host "Process Started - $(Get-Date)"

    if (!$(ConnectionSetup)) { Abort }  # connection setup

    $UserUPN = "edward@udotavigmail.onmicrosoft.com" #temp
    $UserID = GetAdUserID ${UserUPN}  # fetching the user object id
    if (!${UserID}) { Abort }

    $GroupName = "Admin" # temp
    $GroupID = GetAdGroupID ${GroupName}  # fetching the group object id
    if (!${GroupID}) { Abort }

    $AddDrop = "Add" # temp
    $return_code = AddDropGroupMember -GroupID ${GroupID} -UserID ${UserID} -AddDrop ${AddDrop}  # group add/remove
    if (${return_code} -ne 0) { Abort }

    Write-Host "Process Completed - $(Get-Date)"

    return $true
}

if ($MyInvocation.InvocationName -ne '.')
{
main
}

# end