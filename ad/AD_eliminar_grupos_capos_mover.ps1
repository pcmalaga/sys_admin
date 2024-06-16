#### En este ejemplo eliminaremos todos los grupos a los que pertenece el usuario excepto Usuarios del dominio. Luego guardaremos el contenido de dos propiedades y posteriormente las eliminaremos, una vez terminado esto, desactivaremos el usuario y moveremos este a USUARIOS_DESACTIVADOS ####
# Importar módulo de Active Directory
Import-Module ActiveDirectory

# Definir el nombre del usuario de AD
$usuario = "nombre_usuario"

# 1. Eliminar todas las pertenencias a grupos en el apartado de "Member Of", excepto "Usuarios del dominio"
$user = Get-ADUser -Identity $usuario -Properties MemberOf
$grupos = $user.MemberOf

foreach ($grupo in $grupos) {
	# Obtener el nombre del grupo
	$grupoNombre = (Get-ADGroup -Identity $grupo).Name
    
	# Comprobar si el grupo no es "Usuarios del dominio"
	if ($grupoNombre -ne "Usuarios del dominio") {
    	# Eliminar el usuario del grupo
    	Remove-ADGroupMember -Identity $grupo -Members $user -Confirm:$false
	}
}

# 2. Copiar los campos "Department" y "Manager" en un archivo txt
$department = (Get-ADUser -Identity $usuario -Properties Department).Department
$manager = (Get-ADUser -Identity $usuario -Properties Manager).Manager

# Crear un string con la información
$info = "Department: $department`nManager: $manager"

# Guardar la información en un archivo txt
$path = "C:\Capturas\$usuario.txt"
Set-Content -Path $path -Value $info

# 3. Eliminar los campos "Department" y "Manager"
Set-ADUser -Identity $usuario -Department $null -Manager $null

# 4. Desactivar la cuenta y mover al usuario a la carpeta "USUARIOS_DESACTIVADOS"
# Desactivar la cuenta
Disable-ADAccount -Identity $usuario

# Mover el usuario a la OU "USUARIOS_DESACTIVADOS"
Move-ADObject -Identity (Get-ADUser -Identity $usuario).DistinguishedName -TargetPath "OU=USUARIOS_DESACTIVADOS,DC=tuDominio,DC=com"

Write-Host "Proceso de baja de usuario completado para $usuario"
