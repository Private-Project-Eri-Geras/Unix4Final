#!/bin/bash

mostrar_ayuda() {
  # pausar el proceso de rescalado
  kill -SIGSTOP $rescaladoPID
  echo "Este menú solo muestra la información
  sobre las entradas y salidas de sesion.
-El log del archivo lo podras entontrar en:
/var/glam/logs/usrsInOut/usuarios$(date +'%d%m%y').txt" >/var/glam/tmp/ayuda.txt
  dialog --colors --backtitle "INICIOS Y SALIDAS DE SESION" --title "AYUDA" \
    --exit-label "Ok" \
    --textbox /var/glam/tmp/ayuda.txt 0 0 --scrollbar
  rm /var/glam/tmp/ayuda.txt
  # reanudar el proceso de rescalado
  kill -SIGCONT $rescaladoPID
}
# ruta global
ruta="/var/glam/logs/usrsInOut"

nameArch="usuarios$(date +'%d%m%y').txt"
# archivo de usuarios que se encuentran en el sistema (old)
cat "$ruta/$nameArch" >/var/glam/tmp/InOutOld.txt

# Indice de los botones
btnIndex=0

rescalado() {
  while true; do
    # si cambio el tamaño de la ventana, redibujar la ventana
    if [[ $winRows != $(tput lines) || $winCols != $(tput cols) ]]; then
      winRows=$(tput lines)
      winCols=$(tput cols)
      dibujarVentana
    fi
    sleep 0.5
  done
}

# funcion para actualizar el archivo old
isActualizar() {
  nameArch="usuarios$(date +'%d%m%y').txt"
  rutaUsrs="$ruta/$nameArch"
  # archivo de usuarios que se encuentran en el sistema (new)
  cat "$rutaUsrs" >/var/glam/tmp/InOutNew.txt

  # si no hay diferencia entre los archivos, retornar
  if [[ $(diff /var/glam/tmp/InOutOld.txt /var/glam/tmp/InOutNew.txt) == "" ]]; then
    return 1
  fi
  # si hay diferencia, actualizar el archivo old
  cat "$rutaUsrs" >/var/glam/tmp/InOutOld.txt
  return 0
}

dibujarVentana() {
  # tamaño de la ventana
  winRows=$(tput lines)
  winCols=$(tput cols)
  # tamaño del cuadro de dialogo
  dialogRows=$(($winRows - 4))
  dialogCols=$(($winCols - 8))
  # header lines
  headerLines=5 # 1 info y 1 de botones
  # lineas que se pueden mostrar en el cuadro de dialogo
  linesToShow=$(($dialogRows - $headerLines))

  # footer
  footer='\Z1\ZbSeleccionar >> \Zb\Z0[\Z4ESPACIO\Z0]\Zn'
  # botones
  btns=(
    "Salir"
    "Ayuda"
  )
  # cantidad de lineas
  numLines=$(wc -l </var/glam/tmp/InOutNew.txt)

  # error cat: /var/glam/tmp/usuariosInOut.txt/usuarios190623.txt: Not a directory
  # el archivo a leer es uno temporal
  local usrFile="/var/glam/tmp/usersInOut.txt"
  # mostrar las ultimas lineas
  # si una linea no cabe en el ancho del dialog
  # cortar la linea para que tenga 5 caracteres menos que el ancho del dialog
  # y agregarle 3 puntos suspensivos
  touch /var/glam/tmp/usersInOut2.txt
  echo "" >/var/glam/tmp/usersInOut2.txt
  while read -r line; do
    if [[ ${#line} -gt $(($dialogCols + 2)) ]]; then
      echo "${line:0:$(($dialogCols - 5))}\Z1\Zb...\Zn" >>/var/glam/tmp/usersInOut2.txt
    else
      echo "$line" >>/var/glam/tmp/usersInOut2.txt
    fi
  done </var/glam/tmp/InOutNew.txt
  tail -n $linesToShow /var/glam/tmp/usersInOut2.txt >$usrFile

  # agregar el footer
  echo "$footer" >>$usrFile

  for ((i = 0; i < ${#btns[@]}; i++)); do
    # si el indice es igual al indice del boton, resaltar el boton
    if [[ $i == $btnIndex ]]; then
      echo -n "\Zb<\Z4${btns[$i]}\Z0>\Zn   " >>/var/glam/tmp/usersInOut.txt
    else
      echo -n "\Zb<\Z0${btns[$i]}\Zb>\Zn   " >>/var/glam/tmp/usersInOut.txt
    fi
  done
  # mover el cursor a 0 0
  echo -e '\033[0;0H'
  # ocultar el cursor
  echo -e '\033[?25l'
  dialog --colors --keep-window --no-clear --title "Usuarios" --infobox "$(cat $usrFile)" $dialogRows $dialogCols
}

mostrar_cuadro_dialogo() {
  # llamar a la funcion para actualizar el archivo old
  isActualizar
  if [[ $? == 0 ]]; then
    dibujarVentana
  fi
}

# tamaño de la ventana
winRows=$(tput lines)
winCols=$(tput cols)

isActualizar
dibujarVentana

rescalado &
# PID del proceso
rescaladoPID=$!
# Detección de inicios y terminos de sesión
while true; do
  mostrar_cuadro_dialogo
  # Leer la tecla presionada por el usuario
  IFS= read -rsn1 -t 0.5 key

  # comprobar si se presionó una tecla
  if [[ $key == " " ]]; then
    # si el indice es 0, salir
    if [[ $btnIndex == 0 ]]; then
      # mostrar el cursor
      echo -e '\033[?25h'
      # limpiar la pantalla
      clear
      # salir
      break
    fi
    # si el indice es 1, mostrar la ayuda
    if [[ $btnIndex == 1 ]]; then
      mostrar_ayuda
      # redibujar la ventana
      dibujarVentana
    fi
  fi
  # ver si se presiono la flechas izquierda o derecha
  if [[ "$key" == $'\e' ]]; then
    read -rsn1 key
    read -rsn1 key
    # si se presiono la flecha izquierda
    if [[ "$key" == "D" ]]; then
      # si el indice es 1, disminuir el indice
      if [[ $btnIndex -gt 0 ]]; then
        btnIndex=$(($btnIndex - 1))
        dibujarVentana
      fi
    fi
    # si se presiono la flecha derecha
    if [[ "$key" == "C" ]]; then
      # si el indice es 1, aumentar el indice
      if [[ $btnIndex -lt 1 ]]; then
        btnIndex=$(($btnIndex + 1))
        dibujarVentana
      fi
    fi
  fi
done

# matar el proceso de rescalado
kill $rescaladoPID
# remover los archivos temporales
#Exit the script
exit
