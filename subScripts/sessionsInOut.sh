#!/bin/bash
# Ruta del archivo que guarda los inicios y terminos de sesión
new=/tmp/newWho.txt
old=/tmp/oldWho.txt
diferencia=/tmp/diff.txt
archivo=/tmp/usuarios.txt

##### FUNCIONES ####

# Función para mostrar un cuadro de diálogo con las últimas 10 líneas del archivo
mostrar_cuadro_dialogo() {
  dialog --title "Usuarios" --infobox "$(cat "$1")" 0 0
  dialogExit=$?
}

##### CÓDIGO #####

# Posicionar el cursor y mostrar el mensaje fuera del cuadro de diálogo
#echo -e "\033[1;31;44m Presione 'q' para salir     \033[0m"

# Guardando la lista de usuarios conectados
who > "$old"

# Creando el cuadro de diálogo
# Eliminar el archivo temporal
rm -f "$archivo"
touch "$archivo"
mostrar_cuadro_dialogo "$archivo" &

# Detección de inicios y terminos de sesión
while true
do
  who > "$new"
  diff "$old" "$new" > "$diferencia"

  # Obtener los usuarios que entran y mostrarlos en el cuadro de diálogo
  usuarios_entran=$(awk '/>/ { print "in:   " $0 ; }' "$diferencia")
  if [ -n "$usuarios_entran" ]; then
    echo "$usuarios_entran" >> /tmp/usuarios.txt
    mostrar_cuadro_dialogo "/tmp/usuarios.txt"
  fi

  # Obtener los usuarios que salen y mostrarlos en el cuadro de diálogo
  usuarios_salen=$(awk '/</ { print "out:  " $0 ; }' "$diferencia")
  if [ -n "$usuarios_salen" ]; then
      echo "$usuarios_salen" >> /tmp/usuarios.txt
      mostrar_cuadro_dialogo "/tmp/usuarios.txt"
  fi

  mv "$new" "$old"
  
  # Leer la tecla presionada por el usuario
    read -rsn1 -t 1 key

    # Verificar si se presionó la tecla "q" para salir del cuadro de diálogo
    if [[ $key == "q" ]]; then
        break
    fi

done
return
# ------------------usar "break" al usarse en el menu
#Exit the script
#echo "ADIOS!"
#clear
#exit
