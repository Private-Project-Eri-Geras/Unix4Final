#Consiguiendo el tiempo de sesión de cada usuario conectado

who | awk '{print $1,$4,$5}' | while read user login time
do
    # Calcular el tiempo en sesión
    seconds=$(($(date +%s) - $(date -d "$login $time" +%s)))
    formatted_time=$(date -u -d @${seconds} +"%H:%M:%S")

    # Imprimir el usuario y el tiempo en sesión
    echo "Usuario: $user - Tiempo en sesión: $formatted_time"
done