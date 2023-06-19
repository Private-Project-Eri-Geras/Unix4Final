#!/bin/bash
# Script para controlar las acciones a ejecutar al ingresar un usuario
usr=$1  # Se guarda el usuario que inicia sesión

# Verificar si el usuario tiene configurado un respaldo
if [[ -f /usr/src/glam/tareasUsuarios/archs/respaldo.txt ]]; then
    # Verificar si el usuario tiene configurado un respaldo
    while IFS=":" read -r usuario origen destino; do
        if [[ "$usuario" == "$usr" ]]; then
            # Verificar si la ruta de origen existe
            if [[ -e "$origen" ]]; then
                # Obtener el nombre del archivo a respaldar
                nombre=$(basename "$origen")
                # Obtener la fecha actual
                fecha=$(date +"%d-%m-%Y")
                # Obtener la hora actual
                hora=$(date +"%H-%M-%S")
                # Crear el archivo comprimido
                tar -czf "$destino/$nombre"_"$fecha"_"$hora".tar.gz -C "$origen" .
                exit 0  # Salir del bucle después de encontrar la configuración del usuario
            else
                echo "La ruta de origen $origen no existe."
                exit 1
            fi
        fi
    done < /usr/src/glam/tareasUsuarios/archs/respaldo.txt

    # Si se llega a este punto, significa que no se encontró la configuración del usuario
    echo "El usuario $usr no tiene configurado un respaldo."
else
    echo "No se encontró el archivo de configuración /usr/src/glam/tareasUsuarios/archs/respaldo.txt."
    exit 1
fi
