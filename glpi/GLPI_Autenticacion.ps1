# Configurar la URL del servidor GLPI y las credenciales de la API
$glpiUrl = "http://tu-servidor-glpi/apirest.php"
$appToken = "tu-app-token"  # Token de la aplicación
$userToken = "tu-user-token"  # Token del usuario

# Obtener el token de sesión
$response = Invoke-RestMethod -Uri "$glpiUrl/initSession" -Method POST -Headers @{
	"App-Token" = $appToken
	"Authorization" = "user_token $userToken"
}

# Extraer el token de sesión de la respuesta
$sessionToken = $response.session_token
Write-Host "Token de sesión obtenido: $sessionToken"
