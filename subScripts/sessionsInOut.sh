#!/bin/bash
# Ruta del archivo que guarda los inicios y terminos de sesión
new=/tmp/newWho.txt
old=/tmp/oldWho.txt
diferencia=/tmp/diff.txt
archivo="registerInOut/usuarios$(date +'%d%m%y').txt"

##### FUNCIONES ####

# Función para mostrar un cuadro de diálogo con las últimas 10 líneas del archivo
mostrar_cuadro_dialogo() {
  dialog --title "Usuarios" --backtitle "q para salir" --infobox "$( tail -5 $archivo )" 0 0
  dialogExit=$?
}

##### CÓDIGO #####

# Guardando la lista de usuarios conectados
who > "$old"

# Creando el cuadro de diálogo
# Eliminar el archivo temporal

mostrar_cuadro_dialogo

# Detección de inicios y terminos de sesión
while true
do
  archivo="registerInOut/usuarios$(date +'%d%m%y').txt"
  #touch $archivo
  who > "$new"
  diff "$old" "$new" > "$diferencia"

  # Obtener los usuarios que entran y mostrarlos en el cuadro de diálogo
  usuarios_entran=$(awk '/>/ { print "in:   " $0 ; }' "$diferencia")
  if [ -n "$usuarios_entran" ]; then
    echo "$usuarios_entran" >> $archivo
    mostrar_cuadro_dialogo
  fi

  # Obtener los usuarios que salen y mostrarlos en el cuadro de diálogo
  usuarios_salen=$(awk '/</ { print "out:  " $0 ; }' "$diferencia")
  if [ -n "$usuarios_salen" ]; then
      echo "$usuarios_salen" >> $archivo
      mostrar_cuadro_dialogo 
  fi

  mv "$new" "$old"
  
  # Leer la tecla presionada por el usuario
    read -rsn1 -t 1 key

    # Verificar si se presionó la tecla "q" para salir del cuadro de diálogo
    if [[ $key == "q" ]]; then
        break
    fi

    if [[ $key == "\e"]];then

    fi

done

#Exit the script
clear
exit