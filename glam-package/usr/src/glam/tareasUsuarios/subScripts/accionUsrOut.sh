#!/bin/bash
usr=$1 # Nombre del usuario
rutaLogIni="/var/glam/logs/usrsInOut/" # Ruta del archivo de log. (usr:HoraEntrada:HoraSalida)
#busca en la ruta dada un archivo que contenga la palabra usrLog
nameArchLog="usrLog$(date +"-%d-%m-%Y").txt" # Nombre del archivo de log
rutaLog="/var/glam/logs/usrsInOut/$nameArchLog" # Ruta del archivo de log. (usr:HoraEntrada:HoraSalida)
rutaTiempoPermitido="/var/glam/logs/usrsInOut/tiempoPermitido.txt" # Ruta del archivo de tiempo permitido

#Borrando archivos de log antiguos (del día anterior)
# Obtener la lista de archivos que comienzan con "usrLog" y ordenarlos por fecha de modificación
archivos=$(ls -t "${rutaLogIni}usrLog*.txt")

# Obtener el archivo más reciente
archivo_reciente=$(echo "$archivos" | head -n1)

# Mantener el archivo más reciente y eliminar los demás
for archivo in $archivos; do
    if [ "$archivo" != "$archivo_reciente" ]; then
        rm "$archivo"
    fi
done

#Si el nombre del usuario NO se encuentra en el archivo de log sale del script
if [[ $(grep -c "$usr" "$rutaLog") -eq 0 ]]; then
    exit 0
fi

horaSalida=$(date +"%H-%M-%S")

#recorrer linea por linea el archivo de log hasta encontrar el usuario
while IFS=":" read -r usuario hrEntrada hrSalida; do
    if [[ "$usuario" != "$usr" ]]; then
        echo "$usuario:$hrEntrada:$hrSalida" >> $rutaLogIni/usrLogTempN.txt
    else
        if [[ "$hrSalida" == " " ]]; then
            echo "$usuario:$hrEntrada:$horaSalida" >> $rutaLogIni/usrLogTempN.txt
        else
            echo "$usuario:$hrEntrada:$hrSalida" >> $rutaLogIni/usrLogTempN.txt
        fi
    fi
done < $rutaLog


rm $rutaLog
mv $rutaLogIni/usrLogTempN.txt $rutaLog

# Verificar si el usuario tiene configurado un tiempo permitido
while IFS=":" read -r usuario tiempoAdmin tiempoActiv ; do
    if [[ "$usuario" == "$usr" ]]; then
        ./usr/src/glam/tareasUsuarios/subScripts/tiempoSesion/updateArchTimeP.sh $usuario
    fi
done < $rutaTiempoPermitido
