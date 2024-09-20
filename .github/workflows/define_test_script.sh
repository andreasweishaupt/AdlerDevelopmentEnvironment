#!/bin/bash

# Pfad zum Python-Skript
PYTHON_SCRIPT="$GITHUB_WORKSPACE/.github/workflows/test_script.py"

# Funktion zum Finden eines Elements
FIND_ELEMENT() {
    local coordinates=$(python "$PYTHON_SCRIPT" find "$1" "$2" | tail -n 1)
	local coords
    local IFS=',' read -ra coords <<< "$coordinates"
    echo "${coords[@]}"
}

export -f FIND_ELEMENT
