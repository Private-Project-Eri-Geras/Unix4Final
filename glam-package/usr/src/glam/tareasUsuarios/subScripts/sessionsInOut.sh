#!/bin/bash
nameArch="usuarios$(date +'%d%m%y').txt"
  ruta="/var/glam/logs/usrsInOut" 
  rutaUsrs="$ruta/$nameArch"

mostrar_cuadro_dialogo() {
  dialog --title "Usuarios" --backtitle "q para salir" --infobox "$( tail $rutaUsrs )" 0 0
  dialogExit=$?
}

# Detección de inicios y terminos de sesión
while true
do
  nameArch="usuarios$(date +'%d%m%y').txt"
  ruta="/var/glam/logs/usrsInOut" 
  rutaUsrs="$ruta/$nameArch"
  mostrar_cuadro_dialogo

  # Leer la tecla presionada por el usuario
    read -rsn1 -t 1 key

    # Verificar si se presionó la tecla "q" para salir del cuadro de diálogo
    if [[ $key == "q" ]]; then
        break
    fi

done

#Exit the script
clear
exit