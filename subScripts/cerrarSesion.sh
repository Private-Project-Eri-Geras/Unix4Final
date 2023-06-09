#!/bin/bash

usuario="usuario1" #nombre del usuario a cerrar sesión
tiempo_limite=10  # 30 minutos

# Verificar si el usuario ha iniciado sesión
while true; do
    if who | grep -wq "$usuario"; then
        echo "El usuario inicio sesión"
        break
    fi
    echo "..."
    sleep 1
done

# Resto del código para cerrar la sesión después del tiempo límite
pid=$(pgrep -u "$usuario")
sleep "$tiempo_limite"

if ps -p "$pid" > /dev/null; then
    pkill -9 -u "$usuario"  #comando para forzar el cierre de sesión de un usuario
    echo "Se cerró la sesión del usuario '$usuario'."
else
    echo "El usuario $usuario ya ha cerrado la sesión."
fi