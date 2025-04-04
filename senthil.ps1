[CmdletBinding()]
param(
[Parameter(mandatory=$true)]
[string]$AppName,
[Parameter(mandatory=$true)]
[string]$RoleName,
[Parameter(mandatory=$true)]
[string]$userEmail,
[Parameter(Mandatory=$true)]
[string] $secret,
[Parameter(Mandatory=$true)]
[string] $tenantid,
[Parameter(Mandatory=$true)]
[string] $spnid
)
try{
$clientSecret = ConvertTo-SecureString $secret -AsPlainText -Force 

$connectCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $spnid, $clientSecret
Connect-AzAccount -ServicePrincipal -Credential $connectCreds -Tenant $tenantid


$contextX = Get-AzContext
$context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
$graphToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.microsoft.com").AccessToken
$aadToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.windows.net").AccessToken
Write-Output "Connected to account $($context.Account.Id)"
Connect-AzureAD -AadAccessToken $aadToken -AccountId $context.Account.Id -TenantId $context.tenant.id -MsAccessToken $graphToken -Verbose



Write-Host "App Name: $AppName"
Write-Host "Role Name: $RoleName"
Write-Host "User Email: $userEmail"
$app = Get-AzureADApplication -Filter "DisplayName eq '$($AppName)'"
$appRoles = $app.AppRoles


if($appRoles -ne $null)
{
    foreach($appRole in $appRoles)
    {
      if($appRole.DisplayName.ToLower() -eq $RoleName.ToLower() -and $appRole.AllowedMemberTypes -contains "User")
      {
       Write-Host "App Role Name: $($appRole.DisplayName)"
       $roleId = $appRole.Id
       Write-Host "App Role ID: $roleId"
      }
    }
    
    $spn = Get-AzureADServicePrincipal -Filter "AppId eq '$($app.AppId)'"
    $user = Get-AzureADUser -ObjectId "$($userEmail)"
    if($user)
    {
     New-AzureADServiceAppRoleAssignment -Id $roleId -PrincipalId $user.ObjectId -ResourceId $spn.ObjectId -ObjectId $spn.ObjectId
     Write-Host "User has been added to App Role"
    }
}
else { Write-Host "No App Roles present at AD App" }

}
catch{
    Write-Host "notworked"
}

