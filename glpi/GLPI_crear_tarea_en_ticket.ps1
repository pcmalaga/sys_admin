# Install-Module -Name GlpiTools -Scope CurrentUser
# Importar el módulo GlpiTools
Import-Module GlpiTools

# Configurar la URL del servidor GLPI y las credenciales de la API
$glpiUrl = "http://tu-servidor-glpi/apirest.php"
$appToken = "tu-app-token"  # Reemplaza con tu App-Token
$userToken = "tu-user-token"  # Reemplaza con tu User-Token

# Datos para la tarea
$taskName = "new task"
$groupsIdTech = 0
$description = "test"
$begin = "2023-09-09 15:46:17"
$end = "2023-09-10 15:46:17"
$taskCategoriesId = 0
$usersIdTech = 13
$ticketsId = 24  # ID del ticket en el que se desea crear la tarea

# Obtener el token de sesión
$response = Invoke-RestMethod -Uri "$glpiUrl/initSession" -Method POST -Headers @{
	"App-Token" = $appToken
	"Authorization" = "user_token $userToken"
}

# Verificar si se obtuvo el token de sesión correctamente
if ($response.session_token) {
	$sessionToken = $response.session_token
	Write-Host "Token de sesión obtenido: $sessionToken"

	# Crear la tarea en el ticket utilizando GlpiTools
	$taskData = @{
    	"name" = $taskName
    	"groups_id_tech" = $groupsIdTech
    	"description" = $description
    	"begin" = $begin
    	"end" = $end
    	"taskcategories_id" = $taskCategoriesId
    	"users_id_tech" = $usersIdTech
    	"tickets_id" = $ticketsId
	}

	$taskResponse = Add-GlpiToolsTicketTask -GlpiApiUrl $glpiUrl -SessionToken $sessionToken -AppToken $appToken -TaskData $taskData

	if ($taskResponse) {
    	Write-Host "Tarea creada exitosamente en el ticket $ticketsId."
	} else {
    	Write-Host "Error al crear la tarea en el ticket $ticketsId."
	}

	# Cerrar la sesión
	Invoke-RestMethod -Uri "$glpiUrl/killSession" -Method POST -Headers @{
    	"App-Token" = $appToken
    	"Session-Token" = $sessionToken
	}
} else {
	Write-Host "Error al obtener el token de sesión."
}
