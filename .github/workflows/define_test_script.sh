#!/bin/bash

# Pfad zum Python-Skript
PYTHON_SCRIPT="$GITHUB_WORKSPACE/.github/workflows/test_script.py"

# Funktion zum Finden eines Elements
FIND_ELEMENT() {
    python "$PYTHON_SCRIPT" find "$1" "$2"
}

export -f FIND_ELEMENT
