#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
options=()
directories=()

for directory in "$SCRIPT_DIR"/*/; do
  [[ -d "$directory" ]] || continue
  name="${directory%/}"
  name="${name##*/}"
  directories+=("${directory%/}")
  case "$name" in
    nextjs) options+=("NextJS") ;;
    *) options+=("$name") ;;
  esac
done

if [[ ${#options[@]} -eq 0 ]]; then
  printf 'No language or framework folders were found in %s.\n' "$SCRIPT_DIR" >&2
  exit 1
fi

printf 'What language or framework is this project in?\n'
PS3='Select an option (enter its number): '

select option in "${options[@]}"; do
  if [[ -n "$option" ]]; then
    printf 'Selected: %s\n' "$option"
    selected_directory="${directories[REPLY-1]}"
    if [[ ! -f "$selected_directory/index.sh" ]]; then
      printf 'Setup entry point was not found: %s/index.sh\n' "$selected_directory" >&2
      exit 1
    fi
    cd -- "$selected_directory"
    exec bash ./index.sh "$@"
  fi

  printf 'Invalid selection. Please enter a number from the menu.\n' >&2
done
