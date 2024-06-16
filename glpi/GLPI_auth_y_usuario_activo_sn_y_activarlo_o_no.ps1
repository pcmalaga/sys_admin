# Configurar la URL del servidor GLPI y las credenciales de la API
$glpiUrl = "http://tu-servidor-glpi/apirest.php"
$appToken = "tu-app-token"  # Reemplaza con tu App-Token
$userToken = "tu-user-token"  # Reemplaza con tu User-Token
$userId = "usuario_id"  # Reemplaza con el ID del usuario

# Paso 1: Obtener el token de sesión
$response = Invoke-RestMethod -Uri "$glpiUrl/initSession" -Method POST -Headers @{
	"Content-Type" = "application/json"
	"App-Token" = $appToken
	"Authorization" = "user_token $userToken"
}

# Verificar si se obtuvo el token de sesión correctamente
if ($response.session_token) {
	$sessionToken = $response.session_token
	Write-Host "Token de sesión obtenido: $sessionToken"

	# Paso 2: Consultar el estado del usuario
	$userResponse = Invoke-RestMethod -Uri "$glpiUrl/User/$userId" -Method GET -Headers @{
    	"Content-Type" = "application/json"
    	"App-Token" = $appToken
    	"Session-Token" = $sessionToken
	}

	# Imprimir la respuesta completa para depuración
	Write-Host "Respuesta del usuario: " (ConvertTo-Json $userResponse -Depth 10)

	if ($userResponse) {
    	$isActive = $userResponse.is_active
    	Write-Host "Estado actual del usuario: " $isActive

    	# Preguntar si se desea cambiar el estado
    	if ($isActive -eq 1) {
        	$response = Read-Host "El usuario está activo. ¿Desea desactivarlo? (si/no)"
        	if ($response -eq "si") {
            	# Desactivar el usuario
            	$updateResponse = Invoke-RestMethod -Uri "$glpiUrl/User/$userId" -Method PUT -Headers @{
                	"Content-Type" = "application/json"
                	"App-Token" = $appToken
                	"Session-Token" = $sessionToken
            	} -Body (@{"input"=@{"id"=$userId;"is_active"=0}} | ConvertTo-Json)
            	Write-Host "El usuario ha sido desactivado."
        	} else {
            	Write-Host "No se realizaron cambios."
        	}
    	} elseif ($isActive -eq 0) {
        	$response = Read-Host "El usuario está deshabilitado. ¿Desea activarlo? (si/no)"
        	if ($response -eq "si") {
            	# Activar el usuario
            	$updateResponse = Invoke-RestMethod -Uri "$glpiUrl/User/$userId" -Method PUT -Headers @{
                	"Content-Type" = "application/json"
                	"App-Token" = $appToken
                	"Session-Token" = $sessionToken
            	} -Body (@{"input"=@{"id"=$userId;"is_active"=1}} | ConvertTo-Json)
            	Write-Host "El usuario ha sido activado."
        	} else {
            	Write-Host "No se realizaron cambios."
        	}
    	} else {
        	Write-Host "El estado del usuario es desconocido: $isActive"
    	}
	} else {
    	Write-Host "No se pudo obtener el estado del usuario."
	}
} else {
	Write-Host "Error al obtener el token de sesión."
}
