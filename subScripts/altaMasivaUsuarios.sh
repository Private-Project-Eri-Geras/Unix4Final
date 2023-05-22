#!/bin/bash

clear
echo -e "\e[34m╔═══════════════════════════════════════════╗\e[0m"
echo -e "\e[34m║          ALAT MASIVA DE USUARIOS          ║\e[0m"
echo -e "\e[34m╚═══════════════════════════════════════════╝\e[0m"
echo ""

# Especifica el nombre del archivo con los datos de los usuarios
echo "Especifica el nombre del archivo con los datos de los usuarios"
read archivo_usuarios
echo ""

# Verificar si el archivo existe
if [ ! -f "$archivo_usuarios" ]; then
    echo "El archivo $archivo_usuarios no existe."
    echo ""
    echo -e "\e[34mPresiona cualquier tecla para continuar\e[0m"
    read -sn 1
    return
fi

lineaIndex=1

# Obtener el nombre de usuario
usuario_actual="$USER"
# Crear el archivo de registro
log_file="logs/altaMasiva_$(date +%H)_$(date +%M).log"
counter=1

while [ -f "$log_file" ]; do
    log_file="logs/altaMasiva_$(date +%H)_$(date +%M)_($counter).log"
    ((counter++))
done

mkdir -p logs
touch "$log_file"

# Escribir el nombre de usuario en la primera línea del archivo de registro
echo "Usuario: $usuario_actual" >>"$log_file"

# Leer el archivo y procesar los datos
while IFS=',' read -r nombre apellido correo; do
    # Verificar que los datos sean correctos
    if [ -z "$nombre" ] || [ -z "$apellido" ] || [ -z "$correo" ]; then
        mensaje_error="Los datos del usuario en la línea $lineaIndex no son correctos."
        echo "$mensaje_error" >>"$log_file"

        # Incrementar el contador de líneas
        ((lineaIndex++))
        continue
    fi

    # Lógica para crear el usuario
    # Puedes utilizar comandos como useradd, adduser, etc.
    # Por ejemplo:
    # useradd -m -s /bin/bash -c "Nombre Completo" nombre_usuario
    mensaje="Creando usuario $nombre $apellido $correo"
    echo "$mensaje" >>"$log_file"

    ((lineaIndex++))
done <"$archivo_usuarios"

echo "Alta masiva de usuarios completada."
echo -e "Puedes ver el registro en el archivo \e[33m $log_file \e[0m"
echo ""
echo -e "\e[34mPresiona cualquier tecla para continuar\e[0m"
read -sn 1
