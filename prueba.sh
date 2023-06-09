#/bin/bash 
function DialogGen() {
    dialog --radiolist 'radiolist' 15 10 10 'Grapes' 5 'off' 'apple' 2 'off' 'dessert' 3 'off' 'coffee' 4 'on' 
}
DialogGen 