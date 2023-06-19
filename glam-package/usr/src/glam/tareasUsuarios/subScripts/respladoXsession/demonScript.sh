#!/bin/bash

# Función para manejar la acción de inicio de sesión
function handle_login {
    local user=$1
    #echo "El usuario $user ha iniciado sesión" | wall
    #who|grep "$user" >> "/usr/src/glam/tareasUsuarios/archs/usersInOUt.txt"
    ./usr/src/glam/tareasUsuarios/subScripts/accionUsrIn.sh $user
}

# Función para manejar la acción de cierre de sesión
function handle_logout {
    local user=$1
    #echo "El usuario $user ha cerrado sesión" | wall
    #who|grep "$user" >> "/usr/src/glam/tareasUsuarios/archs/usersInOUt.txt"
    ./usr/src/glam/tareasUsuarios/subScripts/accionUsrOut.sh $user
}

# Función principal del demonio
function run_daemon {
    local previous_users=()
    while true; do
        current_users=($(who | awk '{print $1}'))
        
        # Verifica si algún usuario ha iniciado sesión
        for user in "${current_users[@]}"; do
            if ! [[ " ${previous_users[@]} " =~ " ${user} " ]]; then
                handle_login "$user"
            fi
        done
        
        # Verifica si algún usuario ha cerrado sesión
        for user in "${previous_users[@]}"; do
            if ! [[ " ${current_users[@]} " =~ " ${user} " ]]; then
                handle_logout "$user"
            fi
        done
        
        previous_users=("${current_users[@]}")
        sleep 1  # Espera 1 segundo antes de verificar nuevamente
    done
}
run_daemon

