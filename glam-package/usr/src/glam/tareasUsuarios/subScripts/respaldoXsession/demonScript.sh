#!/bin/bash
# Ruta del archivo que guarda los inicios y terminos de sesión
new=/var/glam/tmp/newWho.txt
old=/var/glam/tmp/oldWho.txt
diferencia=/var/glam/tmp/diff.txt
nameArch="usuarios$(date +'%d%m%y').txt"
ruta="/var/glam/logs/usrsInOut" 
rutaUsrs="$ruta/$nameArch"

  mkdir -p $ruta #verifica si existe la ruta, si no existe la crea
  touch $rutaUsrs

##### CÓDIGO #####

# Guardando la lista de usuarios conectados
who > "$old"

# Creando el cuadro de diálogo
touch "$rutaUsrs"

# Detección de inicios y terminos de sesión
while true
do
   #Verifica que la fecha no haya cambiado, si lo hace crea un nuevo archivo
    if [ "$nameArch" != "usuarios$(date +'%d%m%y').txt" ]; then
        nameArch="usuarios$(date +'%d%m%y').txt"
        rutaUsrs="$ruta/$nameArch"
        touch $rutaUsrs
    fi
    #Elimina los archivos en la ruta que tengan más de 7 días
    find $ruta -type f -mtime +7 -exec rm {} \;

  who > "$new"
  diff "$old" "$new" > "$diferencia"

  # Obtener los usuarios que entran y mostrarlos en el cuadro de diálogo
  usuarios_entran=$(awk '/>/ { print "in:   " $0 ; }' "$diferencia")
  if [ -n "$usuarios_entran" ]; then
    echo "$usuarios_entran" >> $rutaUsrs
     #Obten el usuario que entró y ejecuta el script para revisar conf. de usuario
    user=$(echo "$usuarios_entran" | awk '{print $3}')

    #Verificar que el archivo exista
    if [ -f "/usr/src/glam/tareasUsuarios/subScripts/accionUsrIn.sh" ]; then
      ./usr/src/glam/tareasUsuarios/subScripts/accionUsrIn.sh $user
    fi
  fi

  # Obtener los usuarios que salen y mostrarlos en el cuadro de diálogo
  usuarios_salen=$(awk '/</ { print "out:  " $0 ; }' "$diferencia")
  if [ -n "$usuarios_salen" ]; then
      echo "$usuarios_salen" >> $rutaUsrs
       #Obten el usuario que entró y ejecuta el script para revisar conf. de usuario
    user=$(echo "$usuarios_salen" | awk '{print $3}')

    #Verificar que el archivo exista
    if [ -f "/usr/src/glam/tareasUsuarios/subScripts/accionUsrOut.sh" ]; then
      ./usr/src/glam/tareasUsuarios/subScripts/accionUsrOut.sh $user
    fi

  fi

  mv "$new" "$old"
  sleep 1

done
rm $new
rm $old
rm $diferencia
