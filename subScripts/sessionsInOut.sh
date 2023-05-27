#!/bin/bash
# Ruta del archivo que guarda los inicios y terminos de sesión
new=/tmp/newWho.txt
old=/tmp/oldWho.txt
diferencia=/tmp/diff.txt
archivo=/tmp/usuarios.txt
# Función para mostrar un cuadro de diálogo con el contenido del archivo
mostrar_cuadro_dialogo() {
    
    dialog --title "Usuarios" --clear --textbox "$1" 30 30 --default-button "ok"
        
}

# Guardando la lista de usuarios conectados
who > $old

#Creando el cuadro de dialogo 
touch $archivo
mostrar_cuadro_dialogo $archivo

# Detección de inicios y terminos de sesión
while true
do
  who > $new
  diff $old $new > $diferencia

  # Obtener los usuarios que entran y mostrarlos en el cuadro de diálogo
  usuarios_entran=$(awk '/>/ { print "in:   " $0 ; }' $diferencia)
  if [ -n "$usuarios_entran" ]; then
      echo "$usuarios_entran" >> /tmp/usuarios.txt
     press= mostrar_cuadro_dialogo "/tmp/usuarios.txt"
     if [ "$dialog_output" = "ok" ]; then
        #Sale de la lista desplegable de usuarios
          break
      fi
  fi

  # Obtener los usuarios que salen y mostrarlos en el cuadro de diálogo
  usuarios_salen=$(awk '/</ { print "out:  " $0 ; }' $diferencia)
  if [ -n "$usuarios_salen" ]; then
      echo "$usuarios_salen" >> /tmp/usuarios.txt
      mostrar_cuadro_dialogo "/tmp/usuarios.txt"
  fi

  mv $new $old
  sleep 1
done

