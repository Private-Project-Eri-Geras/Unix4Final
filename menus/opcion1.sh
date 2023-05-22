#!/bin/bash

# Especifica el nombre del archivo con los datos de los usuarios
echo "Especifica el nombre del archivo con los datos de los usuarios"
read archivo_usuarios

# Verificar si el archivo existe
if [ ! -f "$archivo_usuarios" ]; then
    echo "El archivo $archivo_usuarios no existe."
    exit 1
fi

clear

# Leer el archivo y procesar los datos
while IFS=',' read -r nombre apellido correo; do
    # verificar que los datos sean correctos
    if [ -z "$nombre" ] || [ -z "$apellido" ] || [ -z "$correo" ]; then
        echo -e "\e[31mLos datos del usuario no son correctos.\e[0m"
        continue
    fi
    # Lógica para crear el usuario
    # Puedes utilizar comandos como useradd, adduser, etc.
    # Por ejemplo:
    # useradd -m -s /bin/bash -c "Nombre Completo" nombre_usuario
    echo -e "Creando usuario \e[32m$nombre $apellido\e[0m con correo \e[32m$correo\e[0m"
done <"$archivo_usuarios"

echo "Alta masiva de usuarios completada."
echo ""
echo "Presiona para continuar"
read -sn 1
