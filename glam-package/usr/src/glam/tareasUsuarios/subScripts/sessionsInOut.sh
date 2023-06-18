#!/bin/bash
# Ruta del archivo que guarda los inicios y terminos de sesión
new=/var/glam/tmp/newWho.txt
old=/var/glam/tmp/oldWho.txt
diferencia=/var/glam/tmp/diff.txt
nameArch="usuarios$(date +'%d%m%y').txt"
ruta="/var/glam/logs/usrsInOut" 
rutaUsrs="$ruta/$nameArch"
##### FUNCIONES ####
  mkdir -p $ruta #verifica si existe la ruta, s ino existe la crea
  touch $rutaUsrs
# Función para mostrar un cuadro de diálogo con las últimas 10 líneas del archivo
mostrar_cuadro_dialogo() {
  dialog --title "Usuarios" --backtitle "q para salir" --infobox "$( tail $rutaUsrs )" 0 0
  dialogExit=$?
}

##### CÓDIGO #####

# Guardando la lista de usuarios conectados
who > "$old"

# Creando el cuadro de diálogo
# Eliminar el archivo temporal
touch "$rutaUsrs"
mostrar_cuadro_dialogo "$rutaUsrs" &

# Detección de inicios y terminos de sesión
while true
do
  who > "$new"
  diff "$old" "$new" > "$diferencia"

  # Obtener los usuarios que entran y mostrarlos en el cuadro de diálogo
  usuarios_entran=$(awk '/>/ { print "in:   " $0 ; }' "$diferencia")
  if [ -n "$usuarios_entran" ]; then
    echo "$usuarios_entran" >> $rutaUsrs
    mostrar_cuadro_dialogo
  fi

  # Obtener los usuarios que salen y mostrarlos en el cuadro de diálogo
  usuarios_salen=$(awk '/</ { print "out:  " $0 ; }' "$diferencia")
  if [ -n "$usuarios_salen" ]; then
      echo "$usuarios_salen" >> $rutaUsrs
      mostrar_cuadro_dialogo 
  fi

  mv "$new" "$old"

  # Leer la tecla presionada por el usuario
    read -rsn1 -t 1 key

    # Verificar si se presionó la tecla "q" para salir del cuadro de diálogo
    if [[ $key == "q" ]]; then
        break
    fi

done
rm $new
rm $old
rm $diferencia

#Exit the script
clear
exit