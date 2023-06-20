#!/bin/bash
rutaGen="/var/glam/logs/usrsInOut/" # Ruta del archivo . (usr:tiempoLimite:tiempoEnSesion)
ruta="$rutaGen/tiempoPermitido.txt" # Ruta del archivo de log. (usr:tiempoLimite:tiempoEnSesion)
rutaTmp="$rutaGen/tiempoPermitidoTmp.txt" # Ruta del archivo de temporal. (usr:tiempoLimite:tiempoEnSesion)

confirmaDialog(){
  user="$1"
  horas="$2"
  minutos="$3"
  #confirma los datos ingresados para continuar
  dialog --title "Confirmación" --yesno "¿Desea establecer el tiempo permitido para el usuario <$user> en <$horas> horas y <$minutos> minutos?" 0 0
  dialogExit=$?
  #Exit if the user presses cancel
  if [ $dialogExit -ne 0 ]; then
    exit
  fi
  return
}

# Obtener todos los usuarios registrados en el sistema (excluyendo los usuarios del sistema por defecto como root)
usuarios=$(grep -E '^[^:]+:[^:]*:[0-9]{4}:[0-9]{4}' /etc/passwd | cut -d: -f1)

# Verificar si no hay usuarios creados
if [ -z "$usuarios" ]; then
#  "No se encontraron usuarios creados en el sistema."
  exit 1
fi

# Convertir los usuarios en un arreglo
usuarios_array=($usuarios)

# Crear un arreglo de opciones para el menú
opciones=()
for usr in "${usuarios_array[@]}"; do
    while IFS=":" read -r usuarioArch timePermitido timeActivo; do
            if [[ "$usr" == "$usuarioArch" ]]; then
              #verifica que timePermitido si sea vacio
              if [[ ! -z "$timePermitido" ]]; then
               
                 # Calcula las horas y minutos según el tiempo permitido en segundos
                  horas=$((timePermitido / 3600))
                  minutos=$(((timePermitido % 3600) / 60))
                  opciones+=("$usr" " Tiempo permitido-> $horas:$minutos")
                  break
              fi
            fi
        done < $ruta
              #verifica que no este dentro de las opciones ni del archivo
                if [[ ! " ${opciones[@]} " =~ " ${usr} " ]]; then
                  opciones+=("$usr" " ")
                fi
done

#Verifica si el archivo "sessionTimes.txt" existe
  touch $ruta #Crea el archivo

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
            # Verificar la opción seleccionada y realizar la acción correspondiente
            # Desplegar el menú para seleccionar los minutos permitidos
            minutos=$(dialog --clear --title "Establecer minutos permitidos" --cancel-label "Cancelar" --ok-label "Seleccionar" --menu "Select:" 0 0 0 0 "min" 1 "min" 5 "min" 10 "min" 15 "min" 20 "min" 25 "min" 30 "min" 35 "min" 40 "min" 45 "min" 50 "min" 55 "min" 59 "min" 2>&1 >/dev/tty)
            dialogExit=$?
                #Exit if the user presses cancel
            if [[ "dialogExit" -eq 1 ]]; then
                exit
            fi

  tiempo_limite=$(( (horas * 60 * 60) + (minutos * 60) ))  # Guarda el tiempo limite en segundos 
 
      if grep -q "$usuario" $ruta; then #verifica si el usuario se encuentra en el archivo
        #recorrer linea por linea el archivo de log para verificar si se encuntra el usuario
        while IFS=":" read -r usuarioArch timePermitido timeActivo; do
            if [[ "$usuario" != "$usuarioArch" ]]; then
                echo "$usuarioArch:$timePermitido:$timeActivo" >> $rutaTmp
            else
              confirmaDialog $usuario $horas $minutos
              echo "$usuario:$tiempo_limite:$timeActivo" >> $rutaTmp
            fi
        done < $ruta

        rm $ruta
        mv $rutaTmp $ruta
      else
        confirmaDialog $usuario $horas $minutos
        echo "$usuario:$tiempo_limite:" >> $ruta
      fi

#verifica si el usuario ya se encuentra activo
pid=$(pgrep -u "$usuario") #Obtiene el proceso del usuario 
if ps -p "$pid" > /dev/null; then #verifica si el usuario sigue activo
  #Si esta activo manda a llamar a cerrar sesión para que lo detecte
    ./usr/src/glam/tareasUsuarios/subScripts/tiempoSesion/cerrarSesion.sh $usuario &
else

exit