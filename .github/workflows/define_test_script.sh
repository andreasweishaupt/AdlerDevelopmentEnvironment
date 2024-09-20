#!/bin/bash

# Pfad zum Python-Skript
PYTHON_SCRIPT="$GITHUB_WORKSPACE/.github/workflows/test_script.py"

# Funktion zum Finden eines Elements
FIND_ELEMENT() {
	local identifier_type="$1"
    local identifier="$2"
    
    # Ausgabe des Funktionsaufrufs
    printf "FIND_ELEMENT(\"%s\",\"%s\")\n" "$identifier_type" "$identifier"
    
    local coordinates=$(python "$PYTHON_SCRIPT" find "$identifier_type" "$identifier" | tail -n 1)
    local IFS=',' read -ra coords <<< "$coordinates"
    echo "${coords[@]}"
}

export -f FIND_ELEMENT
