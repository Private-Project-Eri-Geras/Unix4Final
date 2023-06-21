#!/bin/bash
#Ruta de archivos para configurar el tiempo de sesión permitido
ruta="/var/glam/logs/usrsInOut/tiempoPermitido.txt" 
rutaTmp="/var/glam/logs/usrsInOut/tiempoPermitidoTmp.txt"

nameArchLog="usrLog$(date +"-%d-%m-%Y").txt" # Nombre del archivo de log
archivo="/var/glam/logs/usrsInOut/$nameArchLog" # Ruta del archivo de log. (usr:HoraEntrada:HoraSalida)
touch $rutaLog # Crea el archivo de log si no existe

usuario=$1  # Usuario para el cual se calculará el tiempo total en segundos
tiempo_total=0  # Variable para almacenar el tiempo total en segundos


#Si el usuario no se encuentra en el archivo de tiempo permitido sale
if ! grep -q "$usuario" "$ruta"; then
    exit
fi

# Leer el archivo línea por línea
while IFS=":" read -r usr inicio fin; do
    if [ "$usr" = "$usuario" ]; then
        if [ -n "$inicio" ] && [ -n "$fin" ]; then
            # Convertir los tiempos de inicio y fin a segundos utilizando awk
            inicio_seg=$(echo "$inicio" | awk -F'-' '{ print $1 * 3600 + $2 * 60 + $3 }')
            fin_seg=$(echo "$fin" | awk -F'-' '{ print $1 * 3600 + $2 * 60 + $3 }')

            # Calcular la duración en segundos
            duracion=$((fin_seg - inicio_seg))

            #Lee el archivo del tiempo permitido y guarda el tiempo transcurrido
            while IFS=":" read -r usr permitido activo; do
                if [ "$usr" = "$usuario" ]; then
                    tiempoActivo=$activo
                    break
                fi
            done < "$ruta"

            tiempoNewTot=$((duracion + tiempoActivo))
            # Actualizar el tiempo total en el archivo
            while IFS=":" read -r usr inicio fin; do
                if [ "$usr" != "$usuario" ]; then
                    echo "$usr:$inicio:$fin" >> "$rutaTmp"
                else
                    echo "$usr:$inicio:$tiempoNewTot" >> "$rutaTmp"
                fi
            done < "$ruta"
            rm $ruta
            mv $rutaTmp $ruta
        fi
    fi
done < "$archivo"

exit