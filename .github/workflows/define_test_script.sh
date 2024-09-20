#!/bin/bash

# Pfad zum Python-Skript
PYTHON_SCRIPT="$GITHUB_WORKSPACE/.github/workflows/test_script.py"

# Funktion zum Finden eines Elements
FIND_ELEMENT() {
    local identifier_type="$1"
    local identifier="$2"
    local index="${3:-0}"  # Default to 0 if not provided
    
    local coordinates=$(python "$PYTHON_SCRIPT" find "$identifier_type" "$identifier" "$index" | tail -n 1)
    local coords
    IFS=',' read -ra coords <<< "$coordinates"
    echo "${coords[@]}"
}

export -f FIND_ELEMENT
