#!/bin/bash

# Laden Sie die FIND_ELEMENT Funktion
source $GITHUB_WORKSPACE/.github/workflows/define_test_script.sh
        
echo Click on create-world-button
coords=($(FIND_ELEMENT "class" "create-world-button"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1 sleep 1
DISPLAY=:99 xdotool type "testWorld"
DISPLAY=:99 xdotool sleep 1 key "Return"

echo Click on space-metadata-icon
coords=($(FIND_ELEMENT "src" "space-metadata-icon.png"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1 sleep 1
DISPLAY=:99 xdotool type "testSpace"
DISPLAY=:99 xdotool sleep 1 key "Return"
sleep 1

echo Click on slot ele_0
coords=($(FIND_ELEMENT "identifier" "ele_0"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1 sleep 1

echo Click on adaptivityelement-icon
coords=($(FIND_ELEMENT "src" "adaptivityelement-icon.png"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1 sleep 1
DISPLAY=:99 xdotool type "testElement"
DISPLAY=:99 xdotool sleep 1 key "Return"
sleep 1

echo Click on add-tasks
coords=($(FIND_ELEMENT "class" "add-tasks"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on Neue Aufgabe erstellen
coords=($(FIND_ELEMENT "title" "Aufgabe erstellen"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Neue Aufgabe umbenennen
coords=($(FIND_ELEMENT "type" "text"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
DISPLAY=:99 xdotool sleep 0.5 key "ctrl+a" key "BackSpace" sleep 1
DISPLAY=:99 xdotool type "testAufgabe"
sleep 1

echo Click on Mittelschwer
coords=($(FIND_ELEMENT "text" "Mittelschwer"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on mud-input-root-outlined
coords=($(FIND_ELEMENT "class" "mud-switch-button"))
coords[1]=$((coords[1] - 70))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
DISPLAY=:99 xdotool type "Macht es Spass, Pipelines zu erstellen?"
sleep 1

echo Click on switch-button
coords=($(FIND_ELEMENT "class" "mud-switch-button"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo first radio button
coords=($(FIND_ELEMENT "type" "radio" 0))
coords[0]=$((coords[0] + 60))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
DISPLAY=:99 xdotool sleep 0.5 key "ctrl+a" key "BackSpace" sleep 0.5
DISPLAY=:99 xdotool type "Ja"

echo second radio button
coords=($(FIND_ELEMENT "type" "radio" 1))
coords[0]=$((coords[0] + 60))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
DISPLAY=:99 xdotool sleep 0.5 key "ctrl+a" key "BackSpace" sleep 0.5
DISPLAY=:99 xdotool type "Nein"
coords[0]=$((coords[0] - 60))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on add answer
coords=($(FIND_ELEMENT "class" "mud-button-icon-size-small"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 1 click 1
sleep 1

echo third radio button
coords=($(FIND_ELEMENT "type" "radio" 2))
coords[0]=$((coords[0] + 60))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
DISPLAY=:99 xdotool sleep 0.5 key "ctrl+a" key "BackSpace" sleep 0.5
DISPLAY=:99 xdotool type "Auf jeden Fall!!"
coords[0]=$((coords[0] - 60))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on Erstellen
coords=($(FIND_ELEMENT "text" "Erstellen"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on mud-button-close
coords=($(FIND_ELEMENT "class" "mud-button-close"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on mud-success-text
coords=($(FIND_ELEMENT "class" "mud-success-text"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on upload .mbz
coords=($(FIND_ELEMENT "title" "(.mbz)"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 0.5 click 1
sleep 1

echo Click on mud-button-text-primary
coords=($(FIND_ELEMENT "class" "mud-button-text-primary"))
DISPLAY=:99 xdotool mousemove ${coords[0]} ${coords[1]} sleep 3 click 1
sleep 2

echo "------------"  

echo "Interactions completed"
