#!/bin/bash

# Verificar si curl está instalado
if ! command -v curl &>/dev/null; then
  echo "La utilidad 'curl' no está instalada. Se procederá a instalarla..."

  # Verificar si el sistema utiliza APT o YUM
  if command -v apt &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y curl
  elif command -v yum &>/dev/null; then
    sudo yum update
    sudo yum install -y curl
  else
    echo "No se pudo determinar el administrador de paquetes del sistema. Asegúrate de tener instalada la utilidad 'curl' manualmente."
    exit 1
  fi

  echo "La instalación de 'curl' se completó correctamente."
fi


# Generando y mandando correo electronico
SUBJECT="probando envio de correo"; #asunto
SENDGRID_API_KEY="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"
EMAIL_TO="marianaavilarivera@gmail.com" #DESTINATARIO, correo al que va dirigido
FROM_EMAIL="mortum777@gmail.com"
FROM_NAME="Ingeniero"
MESSAGE="Hola qué tal solo es una prueba para verificar el correcto envio de mensajes";

REQUEST_DATA='{"personalizations": [{ 
                   "to": [{ "email": "'"$EMAIL_TO"'" }],
                   "subject": "'"$SUBJECT"'" 
                }],
                "from": {
                    "email": "'"$FROM_EMAIL"'",
                    "name": "'"$FROM_NAME"'" 
                },
                "content": [{
                    "type": "text/plain",
                    "value": "'"$MESSAGE"'"
                }]
}';

curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
    -H "Authorization: Bearer $SENDGRID_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA"