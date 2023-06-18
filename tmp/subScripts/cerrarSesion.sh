#!/bin/bash

usuario="$1" #nombre del usuario a cerrar sesión
horas="$2"
minutos="$3"
tiempo_limite=$(( (horas * 60 * 60) + (minutos * 60) ))  # Guarda el tiempo limite en segundos
echo "Datos:  Usuario= $usuario  Horas= $horas Minutos=$minutos" 
echo "El tiempo limite es de: $tiempo_limite"

# Verificar si el usuario ha iniciado sesión
while true; do
    if who | grep -wq "$usuario"; then
        echo "El usuario inicio sesión"
        break
    fi
    echo "..."
    sleep 1
done

#Calculando el tiempo que le queda al usuario
who | awk '{print $1,$4,$5}' | while read user login time
    do
        # Calcular el tiempo en sesión
        if [ "$user" == "$usuario" ]; then
            pid=$(pgrep -u "$usuario") #Obtiene el proceso del usuario 
            secUsed=$(($(date +%s) - $(date -d "$login $time" +%s)))
            tiempoRestante=$((tiempo_limite - secUsed)) #Calcula el tiempo que le queda al usuario
            if [ $secUsed -gt $tiempo_limite ]; then #Si el " tiempo usado > tiempo limite" Se cierra la sesión del usuario
                if ps -p "$pid" > /dev/null; then   #Verifica que el usuario aún tenga la sesión iniciada
                    pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
                    echo "Se cerró la sesión del usuario '$usuario'."
                else
                    echo "El usuario $usuario ya ha cerrado la sesión."
                fi
            else
                #deja correr el tiempo que le queda al usuario
                sleep "$tiempoRestante"     #corre el tiempo limite faltante
                if ps -p "$pid" > /dev/null; then
                    pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
                    echo "Se cerró la sesión del usuario '$usuario'."
                else
                    echo "El usuario $usuario ya ha cerrado la sesión."
                fi
            fi
        fi
    done

sleep 10