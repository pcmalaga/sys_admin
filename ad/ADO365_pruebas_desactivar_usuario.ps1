# Definir el nombre del usuario de O365
$userPrincipalName = "usuario@dominio.com"

# 1. Cerrar todas las sesiones del usuario
function Revoke-AzureADUserSessions {
	param (
    	[string]$UserPrincipalName
	)

	$url = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName/revokeSignInSessions"
	$token = Get-AzureADToken

	$headers = @{
    	"Authorization" = "Bearer $token"
    	"Content-Type"  = "application/json"
	}

	Invoke-RestMethod -Uri $url -Headers $headers -Method POST
	Write-Host "Sesiones cerradas para $UserPrincipalName"
}

function Get-AzureADToken {
	param (
    	[string]$TenantId,
    	[string]$ClientId,
    	[string]$ClientSecret
	)

	$body = @{
    	grant_type	= "client_credentials"
    	scope     	= "https://graph.microsoft.com/.default"
    	client_id 	= $ClientId
    	client_secret = $ClientSecret
	}

	$url = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
	$response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
	return $response.access_token
}

# 2. Bloquear el inicio de sesión
Set-MsolUser -UserPrincipalName $userPrincipalName -BlockCredential $true

# 3. Eliminar los grupos a los que pertenece en Azure AD (Entra)
$user = Get-AzureADUser -ObjectId $userPrincipalName
$groups = Get-AzureADUserMembership -ObjectId $user.ObjectId

foreach ($group in $groups) {
	Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $user.ObjectId
}

# 4. Eliminar los dispositivos del usuario
$devices = Get-AzureADUserDevice -ObjectId $user.ObjectId

foreach ($device in $devices) {
	Remove-AzureADDevice -ObjectId $device.ObjectId
}

Write-Host "Proceso de baja de usuario completado para $userPrincipalName"
