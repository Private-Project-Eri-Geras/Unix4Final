#!/usr/bin/env bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox "aqui esta la ayuda" 0 0
}

validarCampo(){
    local cadena=$1
    if [[ $cadena == "" ]]; then
        echo -n "a"
    fi

    if [[ ! "${cadena[0]}" =~ [0-9] ]]; then
        #marcar como invalido
        echo -n " "
    else
        #banderas para detectar errores
        local comaEncountered=0
        local guionEncountered=0
        local strlen=${#cadena} #longitud del string
        for (( i=1; i<$strlen; i++ )); do
            #si el caracter es un numero, continuar
            if [[ "${cadena[$i]}" =~ [0-9] ]]; then
                comaEncountered=0
                guionEncountered=0
            #si no es un numero
            elif [[ "${cadena[$i]}" == "," ]]; then
                #si ya se habia encontrado una coma o guion, dar error
                if [ $comaEncountered -eq 1 || $guionEncountered -eq 1]; then
                    echo -n " "
                    break
                fi
                #validar que no sea el ultimo caracter
                if [ $i -eq $strlen-1 ]; then
                    echo -n " "
                    break
                fi
                #si no, marcar que se encontro una coma
                comaEncountered=1
            elif [[ "${cadena[$i]}" == "-" ]]; then
                #si ya se habia encontrado una coma o guion, dar error
                if [ $comaEncountered -eq 1 || $guionEncountered -eq 1]; then
                    echo -n " "
                    break
                fi
                #validar que no sea el ultimo caracter
                if [ $i -eq $strlen-1 ]; then
                    echo -n " "
                    break
                fi
                #si no, marcar que se encontro un guion
                guionEncountered=1
            else
                #si no es un numero, coma o guion, dar error
                echo -n " "
                break
            fi

        done
    fi
    echo $cadena
}

tiempo(){
    # Parametros:
    # $1 = minuto
    # $2 = hora
    # $3 = dia del mes
    # $4 = mes
    # $5 = dia de la semana
    # Validar que se hayan pasado los 5 parametros
    if [ $# -eq 5 ]; then
        minuto=$1
        hora=$2
        dia=$3
        mes=$4
        semana=$5 
    else
        minuto=""
        hora=""
        dia=""
        mes=""
        semana=""
    fi

    var=$(dialog --title "Frecuencia" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --form "" 15 47 9 \
        "Minuto (0-59)" 1 1 "$minuto" 1 25 15 0 \
        "Hora (0-23)" 2 1 "$hora" 2 25 15 0 \
        "Dia del mes (1-31)" 3 1 "$dia" 3 25 15 0 \
        "Mes (1-12)" 4 1 "$mes" 4 25 15 0 \
        "Dia de la Semana (0-7)" 5 1 "$semana" 5 25 15 0 \
        --stdout)
    minutos=$(echo $var | cut -d' ' -f1)
    hora=$(echo $var | cut -d' ' -f2)
    dia=$(echo $var | cut -d' ' -f3)
    mes=$(echo $var | cut -d' ' -f4)
    semana=$(echo $var | cut -d' ' -f5)

    minutos=$(validarCampo "$minutos")
    if [[ $minutos == 'a' ]]; then
        echo -n '* ' > tmp/cron.tmp
    elif [[ $minutos == " " ]]; then
        echo -n "!$minutos " > tmp/cron.tmp
    else
        echo -n "$minutos " > tmp/cron.tmp
    fi
    
    hora=$(validarCampo "$hora")
    if [[ $hora == 'a' ]]; then
        echo -n '* ' >> tmp/cron.tmp
    elif [[ $hora == " " ]]; then
        echo -n "!$hora " >> tmp/cron.tmp
    else
        echo -n "$hora " >> tmp/cron.tmp
    fi

    dia=$(validarCampo "$dia")
    if [[ $dia == 'a' ]]; then
        echo -n '* ' >> tmp/cron.tmp
    elif [[ $dia == " " ]]; then
        echo -n "!$dia " >> tmp/cron.tmp
    else
        echo -n "$dia " >> tmp/cron.tmp
    fi
    
    mes=$(validarCampo "$mes")
    if [[ $mes == 'a' ]]; then
        echo -n '* ' >> tmp/cron.tmp
    elif [[ $mes == " " ]]; then
        echo -n "!$mes " >> tmp/cron.tmp
    else
        echo -n "$mes " >> tmp/cron.tmp
    fi

    semana=$(validarCampo "$semana")
    if [[ $semana == 'a' ]]; then
        echo -n '*' >> tmp/cron.tmp
    elif [[ $semana == " " ]]; then
        echo -n "!$semana" >> tmp/cron.tmp
    else
        echo -n " $semana" >> tmp/cron.tmp
    fi

    #validar que no haya errores
}

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    # Muestra el menú de frecuencia y cambia la variable $tarea
    tiempo
    clear
    cat tmp/cron.tmp
    read -sn 1

    while true; do
        # si la cadena esta vacia, retornar al script que llamo a este
        if [[ $tarea == "" ]]; then
            return
        fi
        #si no contiene un ! sale del while
        if [[ ! $tarea =~ "!" ]]; then
            break
        fi
        #se le tiene que pasar cada parametro por separado
        #separado por espacios
        tarea=$(tiempo $(echo $tarea | cut -d' ' -f1) $(echo $tarea | cut -d' ' -f2) $(echo $tarea | cut -d' ' -f3) $(echo $tarea | cut -d' ' -f4) $(echo $tarea | cut -d' ' -f5))
    done
    # Se pasa el valor de la variable $tarea a la función ubicacion.sh
    (source "respaldoProgramado/nuevo/ubicacion.sh" $tarea)

    # Limpia la pantalla
    clear
done

# Sale del script
clear
