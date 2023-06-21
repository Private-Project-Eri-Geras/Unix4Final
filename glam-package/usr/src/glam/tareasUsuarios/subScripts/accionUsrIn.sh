#!/bin/bash
# Script para controlar las acciones a ejecutar al ingresar un usuario
usr=$1  # Se guarda el usuario que inicia sesión
rutaResp="/var/glam/backups/respaldoInOut.txt" #Archivo que guarda las configuraciones de respaldo
rutaTiempoPermitido="/var/glam/logs/usrsInOut/tiempoPermitido.txt" # Ruta del archivo de tiempo permitido

nameArchLog="usrLog$(date +"-%d-%m-%Y").txt" # Nombre del archivo de log
rutaLog="/var/glam/logs/usrsInOut/$nameArchLog" # Ruta del archivo de log. (usr:HoraEntrada:HoraSalida)

#Verifica si el archivo de log que existe es del dia de hoy
if [[ -e "$rutaLog" ]]; then
    # Obtener la fecha actual
    fechaActual=$(date +"%d")
    # Obtener la fecha del archivo de log
    fechaLog=$(echo "$rutaLog" | cut -d "-" -f 2)
    # Verificar si el archivo de log es del dia de hoy
    if [[ "$fechaActual" != "$fechaLog" ]]; then
        # Crear un nuevo archivo de log
        nameArchLog="usrLog$(date +"-%d-%m-%Y")"
        rutaLog="/var/glam/logs/usrsInOut/$nameArchLog"
    fi
fi

touch $rutaLog # Crear el archivo si no existe
#obtener la hora actual a la que entra el usuario
horaEntrada=$(date +"%H-%M-%S")
echo "$usr:$horaEntrada: " >> $rutaLog

touch $rutaResp # Crear el archivo si no existe
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
            sleep 1
        else
            # La ruta de origen $origen no existe.
            exit 1
        fi
    fi
done < $rutaResp

touch $rutaTiempoPermitido # Crear el archivo si no existe
# Verificar si el usuario tiene configurado un tiempo permitido
while IFS=":" read -r usuario tiempoAdmin tiempoActiv ; do
    if [[ "$usuario" == "$usr" ]]; then
        if [[ "$tiempoActiv" -ge "$tiempoAdmin" ]]; then
            pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
            break
        else
            ./usr/src/glam/tareasUsuarios/subScripts/tiempoSesion/cerrarSesion.sh $usuario &
        fi
    fi
done < $rutaTiempoPermitido