#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly NEUP_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
readonly LOGICA_SETUP="$NEUP_DIR/logica/setup.sh"

if [[ ! -f "$LOGICA_SETUP" ]]; then
  printf 'Logica setup was not found: %s\n' "$LOGICA_SETUP" >&2
  exit 1
fi

printf 'Running neup.logica setup.\n'
exec bash "$LOGICA_SETUP" "$@"
