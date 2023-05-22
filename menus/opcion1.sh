#!/bin/bash

# Especifica el nombre del archivo con los datos de los usuarios
archivo_usuarios="usuarios.csv"

# Verificar si el archivo existe
if [ ! -f "$archivo_usuarios" ]; then
    echo "El archivo $archivo_usuarios no existe."
    exit 1
fi

clear

# Leer el archivo y procesar los datos
while IFS=',' read -r nombre apellido correo; do
    # Lógica para crear el usuario
    # Puedes utilizar comandos como useradd, adduser, etc.
    # Por ejemplo:
    # useradd -m -s /bin/bash -c "Nombre Completo" nombre_usuario
    # si es la ultima linea salirse
    echo -e "Creando usuario \e[32m$nombre $apellido\e[0m con correo \e[32m$correo\e[0m"
done <"$archivo_usuarios"

echo "Alta masiva de usuarios completada."
echo ""
echo "Presiona para continuar"
read -sn 1
