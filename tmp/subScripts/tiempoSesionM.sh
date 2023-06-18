#!/bin/bash
ruta="/usr/src/glam/tareasUsuarios/subscripts/docs/sessionTimes.txt" 

timeInSession() {
    local login="$1"
    local time="$2"
    
    # Calcular el tiempo en sesión
    seconds=$(( $(date +%s) - $(date -d "$login $time" +%s) ))
    date -u -d "@$seconds" +"%H:%M:%S" # EL '' se toma como un "timestamp" para que date lo tome como referencia en segundos y lo convierta al formato indicado
}

# Obtener todos los usuarios registrados en el sistema (excluyendo los usuarios del sistema por defecto como root)
usuarios=$(grep -E '^[^:]+:[^:]*:[0-9]{4}:[0-9]{4}' /etc/passwd | cut -d: -f1)

# Verificar si no hay usuarios creados
if [ -z "$usuarios" ]; then
#  echo "No se encontraron usuarios creados en el sistema."
  exit 1
fi

# Convertir los usuarios en un arreglo
usuarios_array=($usuarios)

# Crear un arreglo de opciones para el menú
opciones=()
for usuario in "${usuarios_array[@]}"; do
  tiempo_sesion=$(who | awk -v usuario="$usuario" '$1 == usuario { print $1, $4, $5; exit }' | while read -r user login time; do timeInSession "$login" "$time"; done)
  if [ -n "$tiempo_sesion" ]; then
    opciones+=("$usuario" "Tiempo de sesión: $tiempo_sesion")
  else
    opciones+=("$usuario" "")
  fi
done

#Verifica si el archivo "sessionTimes.txt" existe
if [[ ! -e  $ruta]]; then #Si NO existe en la ruta entra
  touch $ruta #Crea el archivo
  for usuario in "${usuarios_array[@]}"; do #Recorre el arreglo de los usuarios en el sistema
    echo "$usuario:">>$ruta #Se guarda el nombre de cada usuario en el archivo, con separador ':' para identificar cada campo
  done
else  #Si existe debe comprobar que los nombres de los usuarios no han cambiado
  for usuario in "${usuarios_array[@]}"; do #Recorre el arreglo de los usuarios en el sistema
    if ! grep -qw "$usuario" "$ruta"; then #Verifica que el usuario si se encunetre en la lista de usrs del archivo
      echo "$usuario:" >> "$archivo" #Si no se encuentra se agrega el nombre del usr al archivo
    fi
  done
fi

# Mostrar el menú y guardar la opción seleccionada
usuario=$(dialog --cursor-off-label --colors --clear --title "Configuración de tiempo en sesión" --cancel-label "Cancelar" --ok-label "Seleccionar" --menu "Seleccione un usuario:" 0 0 0 "${opciones[@]}" 2>&1 >/dev/tty)
dialogExit=$?
#Exit if the user presses cancel
if [[ "dialogExit" -eq 1 ]]; then
    exit
fi

    # Desplegar el menú para seleccionar las horas permitidas
    horas=$(dialog --title "Establecer horas permitidas" --cancel-label "Cancelar" --ok-label "Seleccionar" --menu "Seleccione:" 0 0 0 0 "hrs" 1 "hrs" 2 "hrs" 3 "hrs" 4 "hrs" 5 "hrs" 6 "hrs" 7 "hrs" 8 "hrs" 9 "hrs" 10 "hrs" 11 "hrs" 12 "hrs" 13 "hrs" 14 "hrs" 15 "hrs" 16 "hrs" 17 "hrs" 18 "hrs" 19 "hrs" 20 "hrs" 21 "hrs" 22 "hrs" 23 "hrs" 2>&1 >/dev/tty)
    dialogExit=$?

    #Exit if the user presses cancel
    if [[ "dialogExit" -eq 1 ]]; then
        exit
    fi
        clear
            # Verificar la opción seleccionada y realizar la acción correspondiente
            # Desplegar el menú para seleccionar los minutos permitidos
            minutos=$(dialog --clear --title "Establecer minutos permitidos" --cancel-label "Cancelar" --ok-label "Seleccionar" --menu "Select:" 0 0 0 0 "min" 1 "min" 5 "min" 10 "min" 15 "min" 20 "min" 25 "min" 30 "min" 35 "min" 40 "min" 45 "min" 50 "min" 55 "min" 59 "min" 2>&1 >/dev/tty)
            dialogExit=$?
                #Exit if the user presses cancel
            if [[ "dialogExit" -eq 1 ]]; then
                exit
            fi

        clear

            # Pasar los argumentos al script "setTime.sh"
            echo "Segundos en sesión: $seconds"
            ./subScripts/cerrarSesion.sh "$usuario" "$horas" "$minutos" #Ruta del script principal (SessionsMenu)

echo "Fin del script"
sleep 2

#Exit the script
exit