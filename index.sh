#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
options=()
directories=()
requested_language=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang)
      if [[ $# -lt 2 || -z "$2" ]]; then
        printf '%s\n' 'The --lang option requires a language or framework name.' >&2
        exit 2
      fi
      requested_language="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

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

if [[ -n "$requested_language" ]]; then
  case "$requested_language" in
    nextjs) requested_language='nextjs' ;;
  esac

  selected_directory="$SCRIPT_DIR/$requested_language"
  if [[ ! -d "$selected_directory" || ! -f "$selected_directory/index.sh" ]]; then
    printf 'Setup entry point was not found for --lang %s.\n' "$requested_language" >&2
    exit 1
  fi

  printf 'Selected: %s\n' "$requested_language"
  cd -- "$selected_directory"
  exec bash ./index.sh "$@"
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
