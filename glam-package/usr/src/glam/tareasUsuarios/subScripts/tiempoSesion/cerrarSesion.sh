#!/bin/bash
#Cierra la sesión de un usuario logeado segpun el tiempo de sesión permitido

#Ruta de archivos para configurar el tiempo de sesión permitido
ruta="/var/glam/logs/usrsInOut/tiempoPermitido.txt" 
rutaTmp="/var/glam/logs/usrsInOut/tiempoPermitidoTmp.txt" 

#Para almacenar el tiempo que lleva el usuario en sesión
nameArchLog="usrLog$(date +"-%d-%m-%Y").txt" # Nombre del archivo de log
rutaLog="/var/glam/logs/usrsInOut/$nameArchLog" # Ruta del archivo de log. (usr:HoraEntrada:HoraSalida)
touch $rutaLog # Crea el archivo de log si no existe

usuario="$1" #nombre del usuario a cerrar sesión
pid=$(pgrep -u "$usuario") #Obtiene el proceso del usuario 

updateArch(){ #actualzia el tiempo en sesión del archivo
usuario="$1" #nombre del usuario a cerrar sesión
tiempo_total=0  # Variable para almacenar el tiempo total en segundos

# Leer el archivo línea por línea
while IFS=":" read -r usr inicio fin; do
    if [ "$usr" == "$usuario" ]; then
        if [ -n "$inicio" ] && [ -n "$fin" ]; then
            # Convertir los tiempos de inicio y fin a segundos utilizando awk
            inicio_seg=$(echo "$inicio" | awk -F'-' '{ print $1 * 3600 + $2 * 60 + $3 }')
            fin_seg=$(echo "$fin" | awk -F'-' '{ print $1 * 3600 + $2 * 60 + $3 }')

            # Calcular la duración en segundos
            duracion=$((fin_seg - inicio_seg))

            # Sumar la duración al tiempo total
            tiempo_total=$((tiempo_total + duracion))
        fi
    fi
done < "$archivo"
    
    # Actualizar el tiempo total en el archivo
    while IFS=":" read -r usr inicio fin; do
        if [ "$usr" != "$usuario" ]; then
            echo "$usr:$inicio:$fin" >> "$rutaTmp"
        else
            echo "$usr:$inicio:$tiempo_total" >> "$rutaTmp"
        fi
    done < "$ruta"
    rm $ruta
    mv $rutaTmp $ruta
    return
}

tiempo_limite=0  # Variable para almacenar el tiempo total en segundos
tiempoActivo=0
# Leer el archivo línea por línea
while IFS=":" read -r usr permitido activo; do
    if [[ "$usr" == "$usuario" ]]; then
        tiempo_limite=$permitido
        tiempoActivo=$activo
        if [[ "$tiempoActivo" -ge "$tiempo_limite" ]]; then
            pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
            break
        fi
        break
    fi
done < "$ruta"

#ciclo que dure el tiempoActivo con sleep con for
for (( i=0; i<="$tiempo_limite"; i++ ))
do
    if ps -p "$pid" > /dev/null; then #verifica si el usuario sigue activo
        sleep 1
    else
        break #el usuario ya cerro sesión
    fi
done

if ps -p "$pid" > /dev/null; then #verifica si el usuario sigue activo
    pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
fi
exit