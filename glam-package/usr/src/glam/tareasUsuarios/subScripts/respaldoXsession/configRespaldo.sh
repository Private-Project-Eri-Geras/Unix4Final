#!/bin/bash

archResp="/var/glam/backups/respaldoInOut.txt" #Archivo que guarda las configuraciones de respaldo
archRespTmp="/var/glam/backups/respaldoInOutTmp.txt"
mostrar_ayuda1(){
  echo "
    En este menú hay 2 opciones:
     - Ver carpetas respaldadas
        Muestra el contenido del archivo 
        de configuración de respaldo.
     - Configurar carpetas respaldadas
        Permite configurar las carpetas 
        que se respaldarán al iniciar sesión
        el usuario seleccionado dentro del mismo.
   
  " > "/tmp/ayudaInOut.txt"
  dialog --backtitle "GESTIÓN DE USUARIOS" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /tmp/ayudaInOut.txt 0 0
    rm /tmp/ayudaInOut.txt
}

mostrar_ayuda2(){
    echo "
        En este menú se establecen respaldos 
        al iniciar sesión el usuario seleccionaro.

        Esta información se almacena 
        en un archivo en la ruat:
        "/var/glam/backups/respaldoInOut.txt"

        El archivo contiene la siguiente información:
        (usuario:origen:destino)

            usuario: Nombre del usuario
            origen: Ruta del archivo o carpeta a respaldar
            destino: Ruta donde se guardará el respaldo
        
        Seleccionar:
            Al seleccionar un usuario se mostrará
            se desplegará una ventana en la cuál
            se debe seleccionar el archivo o carpeta
            del que se desea hacer un respaldo.
        
        Cancelar:
            Al seleccionar esta opción se cancelará
            la configuración de respaldo para el usuario
            seleccionado.
     
    " > "/tmp/ayudaInOut.txt"
    dialog --backtitle "RESPALDOS POR USUARIO" --title "AYUDA" \
            --exit-label "Ok" \
            --textbox /tmp/ayudaInOut.txt 0 0 
        rm /tmp/ayudaInOut.txt
}

mostrar_ayuda3(){
    echo "
        Auí se muestra la información guardada
        en el archivo de configuración de respaldo.

        En caso de no existir ningún respaldo existente 
        se mostrará un mensaje indicando que no hay
        respaldos configurados. Si se desea añadir 
        algún respaldo se debe seleccionar la opción
        en el menú de configuración de respaldos.
     
    " > "/tmp/ayudaInOut.txt"
    dialog --backtitle "RESPALDOS POR USUARIO" --title "AYUDA" \
            --exit-label "Ok" \
            --textbox /tmp/ayudaInOut.txt 0 0
        rm /tmp/ayudaInOut.txt
}

opt=(
    1 "Ver carpetas respaldadas"
    2 "Configurar carpetas respaldadas" 
)
#FUNCIONES
configResp(){
    usr=$1  #Guarda el usuario seleccionado
    tempfile="/var/glam/tmp/respaldoTmp.txt"
    while true; do
        #Guarda la carpeta/archivo a respaldar al iniciar sesión el usuario
        origen=$(dialog --title "Selecciona un archivo o directorio a respaldar" \
            --cancel-label "Cancelar" \
            --stdout --cursor-off-label --fselect /home/ 14 70)
        opcion=$?

    
        if [[ "opcion" -eq 1 ]]; then  #Exit if the user presses cancel
            return
        fi

        #Guarda la ruta para guardar el respaldo
        destino=$(dialog --title "Selecciona un directorio para guardar el respaldo" \
            --cancel-label "Cancelar" \
            --stdout --cursor-off-label --dselect /home/ 14 70)
        opcion=$?

        if [[ "opcion" -eq 1 ]]; then  #Exit if the user presses cancel
            return
        fi

        #Verificar si la ruta de origen y destino existen
        if [[ -e "$origen" && -e "$destino" ]]; then
            #Obtener el nombre del archivo a respaldar
            nombre=$(basename "$origen")
            #Obtener la fecha actual
            fecha=$(date +"%d-%m-%Y")
            #Obtener la hora actual
            hora=$(date +"%H-%M-%S")
            
            #Desplegar dialog para confirmar los datos ingresados
            dialog --title "Confirmación de datos" --yesno "¿Desea guardar la configuración? \n Al ingresar: $usr \n Ruta a respaldar: $origen \n Destino: $destino" 0 0
            opcion=$?
            if [[ "opcion" -eq 1 ]]; then  #Return if the user presses NO
                return
            fi
            #Continua si el usuario presiona YES

            #Guardar la configuración en el archivo de configuración
            echo "$usr:$origen:$destino" >> $archResp
            return

        else
            #Una de las rutas no existe
            #desplegar dilog -yesno para preguntar si desea volver a intentar
            dialog --title "Error" --yesno "Una de las rutas NO existe \n Ruta a respaldar: $origen \n Destino: $destino \n ¿Desea volver a establecer las ruta?" 0 0
            opcion=$?
            if [[ "opcion" -eq 1 ]]; then  #Return if the user presses NO
                return
            fi
            #Si el usuario presiona YES, se vuelve a ejecutar el ciclo
        fi
    done
}


#subMenu verARch/configurar (Se meustra lista de usuarios)
verArchRespaldos() {
    #Verifica si existe el archivo de configuración
    if [[ ! -f $archResp ]]; then
        #Si no existe muestra un dialog con un mensaje de error
        dialog --title "Sin respaldos programados" --msgbox "No hay ningún respaldo programado al iniciar sesión" 20 80
    else #si existe, muestra el contenido del archivo, el contenido del textbox se despliega en 3 columnas (usuario, origen, destino)
        dialog --title "Respaldos programados" --textbox $archResp 0 80
        return
    fi
}

menuUsrs() {
   # Obtener todos los usuarios registrados en el sistema (excluyendo los usuarios del sistema)
    usuarios=$(grep -E '^[^:]+:[^:]*:[0-9]{4}:[0-9]{4}' /etc/passwd | cut -d: -f1)

    # Verificar si no hay usuarios creados
    if [ -z "$usuarios" ]; then
    # "No se encontraron usuarios creados en el sistema."
    return
    fi

    # Convertir los usuarios en un arreglo
    usuarios_array=($usuarios)

    # Crear un arreglo de opciones para el menú
    opciones=()
    for usuario in "${usuarios_array[@]}"; do
        #Busca si el usuario ya tiene un respaldo programado
        if [[ $(grep -c "$usuario" "$archResp") -eq 0 ]]; then
            #Si no tiene respaldo programado, se agrega la opción para configurar el respaldo
            opciones+=("$usuario" "Configurar respaldo")
        else
            #Si ya tiene respaldo programado, se agrega la opción para ver el respaldo
            opciones+=("$usuario" "Con respaldo")
        fi
    done

    # Mostrar el menú y guardar la opción seleccionada
    usuario=$(dialog --cursor-off-label --colors --clear --title \
    "Establecer cuando se hace el respaldo" --cancel-label "Cancelar" \
    --ok-label "Seleccionar" \
    --help-button --help-label "Ayuda" \
    --extra-button --extra-label "Borrar" \
    --menu "Seleccione un usuario:" 0 0 0 "${opciones[@]}" 2>&1 >/dev/tty)

    opcion=$?

    if [[ "opcion" -eq 1 ]]; then  #Exit if the user presses cancel
        exit
    fi

    #Si selecciona el help buton
    if [[ "opcion" -eq 2 ]]; then
        mostrar_ayuda2
        menuUsrs
        exit
    fi

    #Elimina el tiempo permitido del usuario seleccionado
        if [[ "dialogExit" -eq 3 ]]; then 
        # Actualizar el tiempo total en el archivo
            #Busca si el usuario ya tenía una configuración de respaldo
            while IFS=":" read -r usuario origen destino; do
                if [[ "$usuario" != "$usr" ]]; then
                    echo "$usuario:$origen:$destino" >> $archRespTmp
                fi
            done < $archResp
            #Reemplazar el archivo original con el temporal
            rm $archResp
            mv $archRespTmp $archResp
            menuUsrs
            sleep 15
            exit
        fi

    configResp "$usuario"
    return
}

################################################################
#Print the menu using dialog
    while true; do
        #Mostrar le menu y cambiar el valor de la variable "$selected"
        selected=$(dialog --cursor-off-label --colors --clear --title "Respaldos al iniciar sesión"\
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${opt[@]}" \
        --output-fd 1)
            # ancho, alto, alto del menu interno
        dialogExit=$?

        #Exit if the user presses cancel
        if [[ "dialogExit" -eq 1 ]]; then
            exit
        fi

        #Si selecciona el help buton
        if [[ "dialogExit" -eq 2 ]]; then
            mostrar_ayuda1
            (source "/usr/src/glam/tareasUsuarios/subScripts/respaldoXsession/configRespaldo.sh")
            exit
        fi

        #Si se selecciono una de las opciones:
        case $selected in
        1)
            verArchRespaldos
            ;;
        2)
           menuUsrs
            ;;
        *)
            dialog --colors --title "\Z1ERROR" --msgbox "Opción inválida" 0 0
            ;;
        esac
        clear
    done

#Exit the script
clear
exit