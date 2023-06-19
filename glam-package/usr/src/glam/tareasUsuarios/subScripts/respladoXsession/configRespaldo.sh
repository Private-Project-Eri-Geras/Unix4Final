#!/bin/bash

archResp="/usr/src/glam/tareasUsuarios/archs/respaldo.txt" #Archivo que guarda las configuraciones de respaldo
opt=(
    1 "Ver carpetas respaldadas"
    2 "Configurar carpetas respaldadas" 
)
###############################################################
#FUNCIONES
configResp(){
    usr=$1  #Guarda el usuario seleccionado
    tempfile="/var/glam/tmp/respaldoTmp.txt"
    while true; do
        #Guarda la carpeta/archivo a respaldar al iniciar sesión el usuario
        origen=$(dialog --title "Selecciona un archivo o directorio a respaldar" \
            --cancel-label "Cancelar" \
            --help-button --help-label "Ayuda" \
            --stdout --cursor-off-label --fselect /home/ 14 70)
        opcion=$?

    
        if [[ "opcion" -eq 1 ]]; then  #Exit if the user presses cancel
            return
        fi

        #Guarda la ruta para guardar el respaldo
        destino=$(dialog --title "Selecciona un directorio para guardar el respaldo" \
            --cancel-label "Cancelar" \
            --help-button --help-label "Ayuda" \
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
            #Busca si el usuario ya tenía una configuración de respaldo
            while IFS=":" read -r usuario origen destino; do
                if [[ "$usuario" == "$usr" ]]; then
                    #Si ya tenía una configuración, se elimina
                    sed "/^$nameUsr:/d" "$archResp" > "$tempfile"

                    #Guardar la configuración en el archivo de configuración temporal
                    echo "$usr:$origen:$destino" >> $tempfile

                    # Reemplazar el archivo original con el archivo temporal
                    mv "$tempfile" "$archResp"
                    return
                fi
            done < $archResp

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
        dialog --title "Sin respaldos programados" --msgbox "No hay ningún respaldo programado al iniciar sesión" 0 0
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
    #echo "No se encontraron usuarios creados en el sistema."
    return
    fi

    # Convertir los usuarios en un arreglo
    usuarios_array=($usuarios)

    # Crear un arreglo de opciones para el menú
    opciones=()
    for usuario in "${usuarios_array[@]}"; do
        opciones+=("$usuario" "")
    done

    # Mostrar el menú y guardar la opción seleccionada
    usuario=$(dialog --cursor-off-label --colors --clear --title \
    "Establecer cuando se hace el respaldo" --cancel-label "Cancelar" \
    --ok-label "Seleccionar" --menu "Seleccione un usuario:" 0 0 0 "${opciones[@]}" 2>&1 >/dev/tty)

    opcion=$?
    if [[ "opcion" -eq 1 ]]; then  #Exit if the user presses cancel
        return
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
        --menu "Seleccione una opción:" 0 0 0 "${opt[@]}" \
        --output-fd 1)
            # ancho, alto, alto del menu interno
        dialogExit=$?

        #Exit if the user presses cancel
        if [[ "dialogExit" -eq 1 ]]; then
            break
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