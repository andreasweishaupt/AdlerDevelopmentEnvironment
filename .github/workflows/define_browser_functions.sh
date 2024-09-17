#!/bin/bash

# Pfad zum Python-Skript
PYTHON_SCRIPT="$GITHUB_WORKSPACE/.github/workflows/browser_functions.py"

# Funktion zum Initialisieren des Browsers
INIT_BROWSER() {
    python "$PYTHON_SCRIPT" init
}

# Funktion zum Navigieren zu einer URL
NAVIGATE_TO() {
    python "$PYTHON_SCRIPT" navigate "$1"
}

# Funktion zum Finden eines Elements
GET_ELEMENT_POSITION() {
    python "$PYTHON_SCRIPT" find "$1" "$2" "${3:-}" "${4:-}"
}

# Funktion zum Schließen des Browsers
CLOSE_BROWSER() {
    python "$PYTHON_SCRIPT" close
}


export -f INIT_BROWSER
export -f NAVIGATE_TO
export -f GET_ELEMENT_POSITION
export -f CLOSE_BROWSER