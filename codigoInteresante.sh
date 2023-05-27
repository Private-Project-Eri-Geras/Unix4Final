

# Instalar dialog si no está presente
if ! command -v dialog >/dev/null 2>&1; then
    sudo apt-get install -y dialog
fi