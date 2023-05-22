#!/bin/bash

# Especifica el nombre del archivo con los datos de los usuarios
archivo_usuarios="usuarios.csv"

# Verificar si el archivo existe
if [ ! -f "$archivo_usuarios" ]; then
    echo "El archivo $archivo_usuarios no existe."
    exit 1
fi

# Leer el archivo y procesar los datos
while IFS=',' read -r nombre apellido correo
do
    # Lógica para crear el usuario
    # Puedes utilizar comandos como useradd, adduser, etc.
    # Por ejemplo:
    # useradd -m -s /bin/bash -c "Nombre Completo" nombre_usuario
    echo "Creando usuario: $nombre $apellido ($correo)"
done < "$archivo_usuarios"

echo "Alta masiva de usuarios completada."
echo ""
echo "Presiona para continuar"
read -sn 1