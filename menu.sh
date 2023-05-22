#!/bin/bash

# Función que llama al subShell
subShell() {
    case $1 in
    0)
        source "subScripts/altaMasivaUsuarios.sh"
        ;;
    1)
        source "subScripts/opcion2.sh"
        ;;
    2)
        source "subScripts/opcion3.sh"
        ;;
    esac
    selected=0
    clear
}

# Define the options
options=(
    "Dar de alta masiva a usuarios por archivo"
    "Option 2"
    "Option 3"
    "Exit"
)

# Initialize the selected option
selected=0

# Save the escape sequences for colors in variables
color_blue=$(tput setaf 4)
color_green=$(tput setaf 2)
color_reset=$(tput sgr0)

# Set cursor scrolling speed to max (0)
tput csr 0

clear
# Print the menu
while true; do

    # Move the cursor to the start of the menu
    tput cup 0 0 #gotoxy 0 0

    # Print the menu header
    echo "${color_blue}╔═══════════════════════════════════════════╗${color_reset}"
    echo "${color_blue}║               MENU PRINCIPAL              ║${color_reset}"
    echo "${color_blue}╚═══════════════════════════════════════════╝${color_reset}"
    echo ""

    # Print the options
    for ((i = 0; i < ${#options[@]}; i++)); do
        msg="   ${options[$i]}"
        if [[ $i -eq $selected ]]; then
            echo "${color_green}$msg${color_reset}"
        else
            echo "$msg"
        fi
    done

    # Obtain the user input
    read -sn 1 key

    # Handle the user input
    case $key in
    "j") # arrow up
        if [[ $selected -gt 0 ]]; then
            selected=$((selected - 1))
        else
            selected=$((${#options[@]} - 1))
        fi
        ;;
    "k") # arrow down
        if [[ $selected -lt $((${#options[@]} - 1)) ]]; then
            selected=$((selected + 1))
        else
            selected=0
        fi
        ;;
    "") # enter
        if [[ $selected -eq $((${#options[@]} - 1)) ]]; then
            echo "Saliendo..."
            break
        fi
        subShell $selected
        ;;
    esac
done

# Reset cursor scrolling speed to default (redirect output to /dev/null)
tput csr >/dev/null

# Exit the script
exit
