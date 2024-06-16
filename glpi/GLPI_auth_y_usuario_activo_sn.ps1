# Configurar la URL del servidor GLPI y las credenciales de la API
$glpiUrl = "http://tu-servidor-glpi/apirest.php"
$appToken = "tu-app-token"  # Reemplaza con tu App-Token
$userToken = "tu-user-token"  # Reemplaza con tu User-Token

# Obtener el token de sesión
$response = Invoke-RestMethod -Uri "$glpiUrl/initSession" -Method POST -Headers @{
	"App-Token" = $appToken
	"Authorization" = "user_token $userToken"
}

# Verificar si se obtuvo el token de sesión correctamente
if ($response.session_token) {
	$sessionToken = $response.session_token
	Write-Host "Token de sesión obtenido: $sessionToken"

	# Definir el ID o login del usuario que deseas consultar
	$userId = "usuario_login"  # Reemplaza con el ID o login del usuario

	# Consultar el estado del usuario
	$userResponse = Invoke-RestMethod -Uri "$glpiUrl/User/$userId" -Method GET -Headers @{
    	"App-Token" = $appToken
    	"Session-Token" = $sessionToken
	}

	# Imprimir la respuesta completa para depuración
	Write-Host "Respuesta del usuario: " (ConvertTo-Json $userResponse -Depth 10)

	# Mostrar si el usuario está activo o no
	if ($userResponse) {
    	$isActive = $userResponse.is_active
    	if ($isActive -eq 1) {
        	Write-Host "El usuario está activo."
    	} elseif ($isActive -eq 0) {
        	Write-Host "El usuario está deshabilitado."
    	} else {
        	Write-Host "El estado del usuario es desconocido: $isActive"
    	}
	} else {
    	Write-Host "No se pudo obtener el estado del usuario."
	}
} else {
	Write-Host "Error al obtener el token de sesión."
}
