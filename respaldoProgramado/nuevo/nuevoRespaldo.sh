#!/bin/bash

mkdir -p tmp

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox "aqui esta la ayuda" 0 0
}

validarCampo() {
    local cadena=$1
    if [ -z "$cadena" ]; then
        echo -n "1" >tmp/output.tmp
        return
    fi

    # si el campo es un * retronar 1
    if [ "$cadena" == "*" ]; then
        echo -n "1" >tmp/output.tmp
        return
    fi

    # si el primer caracter no es un numero, dar error
    if [[ ! "${cadena:0:1}" =~ [0-9] ]]; then
        #marcar como invalido
        echo -n "2" >tmp/output.tmp
        return
    else
        #banderas para detectar errores
        local comaEncountered=0
        local guionEncountered=0
        local strlen=${#cadena} #longitud del string
        for ((i = 1; i < $strlen; i++)); do
            #si el caracter es un numero, continuar
            if [[ ${cadena:$i:1} =~ [0-9] ]]; then
                comaEncountered=0
                guionEncountered=0
                echo -n "0" >tmp/output.tmp
            #si no es un numero
            elif [[ ${cadena:$i:1} == "," ]]; then
                #si ya se habia encontrado una coma o guion, dar error
                if [ $comaEncountered -eq 1 ] || [ $guionEncountered -eq 1 ]; then
                    echo -n "2" >tmp/output.tmp
                    return
                fi
                #validar que no sea el ultimo caracter
                if [ $i -eq $((strlen - 1)) ]; then
                    echo -n "2" >tmp/output.tmp
                    return
                fi
                #si no, marcar que se encontro una coma
                comaEncountered=1
            elif [[ ${cadena:$i:1} == "-" ]]; then
                #si ya se habia encontrado una coma o guion, dar error
                if [ $comaEncountered -eq 1 ] || [ $guionEncountered -eq 1 ]; then
                    echo -n "2" >tmp/output.tmp
                    return
                fi
                #validar que no sea el ultimo caracter
                if [ $i -eq $((strlen - 1)) ]; then
                    echo -n "2" >tmp/output.tmp
                    return
                fi
                #si no, marcar que se encontro un guion
                guionEncountered=1
            else
                #si no es un numero, coma o guion, dar error
                echo -n "2" >tmp/output.tmp
                return
            fi

        done
    fi
    echo -n "0" >tmp/output.tmp
}

tiempo() {
    # Parametros:
    # $1 = minuto
    # $2 = hora
    # $3 = dia del mes
    # $4 = mes
    # $5 = dia de la semana
    # Validar que se hayan pasado mas de 0 parametros

    dialog --title "Frecuencia" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --form "" 15 47 9 \
        "Minuto (0-59)" 1 1 "$1" 1 25 15 0 \
        "Hora (0-23)" 2 1 "$2" 2 25 15 0 \
        "Dia del mes (1-31)" 3 1 "$3" 3 25 15 0 \
        "Mes (1-12)" 4 1 "$4" 4 25 15 0 \
        "Dia de la Semana (0-7)" 5 1 "$5" 5 25 15 0 \
        2>tmp/Doutput.tmp
    output=$?
    # Si se presiono el boton de cancelar
    if [ $output -eq 1 ]; then
        echo -n "1" >tmp/dialogOutput.tmp
        return
    # Si se presiono el boton de ayuda
    elif [ $output -eq 2 ]; then
        echo -n "2" >tmp/dialogOutput.tmp
        return
    else
        echo -n "0" >tmp/dialogOutput.tmp
    fi

    minutos=$(head -1 tmp/Doutput.tmp)
    hora=$(head -2 tmp/Doutput.tmp | tail -1)
    dia=$(head -3 tmp/Doutput.tmp | tail -1)
    mes=$(head -4 tmp/Doutput.tmp | tail -1)
    semana=$(head -5 tmp/Doutput.tmp | tail -1)

    validarCampo "$minutos"
    if [[ $(cat tmp/output.tmp) == "1" ]]; then
        echo -n '* ' >tmp/cron.tmp
    elif [[ $(cat tmp/output.tmp) == "2" ]]; then
        echo -n "!$minutos " >tmp/cron.tmp
    else
        echo -n "$minutos " >tmp/cron.tmp
    fi
    rm tmp/output.tmp

    validarCampo "$hora"
    if [[ $(cat tmp/output.tmp) == "1" ]]; then
        echo -n '* ' >>tmp/cron.tmp
    elif [[ $(cat tmp/output.tmp) == "2" ]]; then
        echo -n "!$hora " >>tmp/cron.tmp
    else
        echo -n "$hora " >>tmp/cron.tmp
    fi
    rm tmp/output.tmp

    validarCampo "$dia"
    if [[ $(cat tmp/output.tmp) == "1" ]]; then
        echo -n '* ' >>tmp/cron.tmp
    elif [[ $(cat tmp/output.tmp) == "2" ]]; then
        echo -n "!$dia " >>tmp/cron.tmp
    else
        echo -n "$dia " >>tmp/cron.tmp
    fi
    rm tmp/output.tmp

    validarCampo "$mes"
    if [[ $(cat tmp/output.tmp) == "1" ]]; then
        echo -n '* ' >>tmp/cron.tmp
    elif [[ $(cat tmp/output.tmp) == "2" ]]; then
        echo -n "!$mes " >>tmp/cron.tmp
    else
        echo -n "$mes " >>tmp/cron.tmp
    fi
    rm tmp/output.tmp

    validarCampo "$semana"
    if [[ $(cat tmp/output.tmp) == "1" ]]; then
        echo -n '* ' >>tmp/cron.tmp
    elif [[ $(cat tmp/output.tmp) == "2" ]]; then
        echo -n "!$semana " >>tmp/cron.tmp
    else
        echo -n "$semana " >>tmp/cron.tmp
    fi
    #validar que no haya errores
}

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    # Muestra el menú de frecuencia y cambia la variable $tarea
    tiempo
    while true; do
        # si la cadena esta vacia, retornar al script que llamo a este
        if [[ $(cat tmp/dialogOutput.tmp) -eq 1 ]]; then
            rm -f tmp/cron.tmp
            rm -f tmp/Doutput.tmp
            rm -f tmp/output.tmp
            rm -f tmp/dialogOutput.tmp
            #return
            # TODO: regresar al menu anterior ==========================
            exit
        # si se presiono el boton de ayuda, mostrar ayuda
        elif [[ $(cat tmp/dialogOutput.tmp) == 2 ]]; then
            mostrar_ayuda
            tiempo
            continue
        #si no contiene un ! sale del while
        elif [[ ! $(cat tmp/cron.tmp) =~ "!" ]]; then
            break
        fi
        campo1=$(cat tmp/cron.tmp | cut -d' ' -f1)
        campo2=$(cat tmp/cron.tmp | cut -d' ' -f2)
        campo3=$(cat tmp/cron.tmp | cut -d' ' -f3)
        campo4=$(cat tmp/cron.tmp | cut -d' ' -f4)
        campo5=$(cat tmp/cron.tmp | cut -d' ' -f5)
        if [[ $(cat tmp/cron.tmp | cut -d' ' -f1) == '*' ]]; then
            campo1=""
        fi
        if [[ $(cat tmp/cron.tmp | cut -d' ' -f2) == '*' ]]; then
            campo2=""
        fi
        if [[ $(cat tmp/cron.tmp | cut -d' ' -f3) == '*' ]]; then
            campo3=""
        fi
        if [[ $(cat tmp/cron.tmp | cut -d' ' -f4) == '*' ]]; then
            campo4=""
        fi
        if [[ $(cat tmp/cron.tmp | cut -d' ' -f5) == '*' ]]; then
            campo5=""
        fi
        #se le tiene que pasar cada parametro por separado
        #separado por espacios
        tiempo "$campo1" "$campo2" "$campo3" "$campo4" "$campo5"
    done
    echo -n "root " >>tmp/cron.tmp
    echo -n "" >tmp/cancelar.tmp
    # Si el archivo tmp/cancelar no existe, se hace un break
    (source "respaldoProgramado/nuevo/origen.sh")
    if [[ ! -f tmp/cancelar.tmp ]]; then
        break
    fi
    # Limpia la pantalla
    clear
done

# Sale del script
rm -f tmp/cron.tmp
rm -f tmp/Doutput.tmp
rm -f tmp/output.tmp
rm -f tmp/dialogOutput.tmp
clear
