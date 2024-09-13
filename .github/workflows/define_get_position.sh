#!/bin/bash

GET_POSITION() {
  python "$GITHUB_WORKSPACE/.github/workflows/find_element.py" "$1" "$2" "${3:-}" "${4:-}" "${5:-}"
}

export -f GET_POSITION
