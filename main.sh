#!/usr/bin/env bash
set -euo pipefail

default_log="access.log"
input_source=""

error_missing_file() {
  printf 'Error: log file not found: %s\n' "$1" >&2
  exit 1
}

if [[ $# -gt 0 ]]; then
  input_source=$1
  [[ -f "${input_source}" ]] || error_missing_file "${input_source}"
elif [[ -p /dev/stdin ]]; then
  input_source=/dev/stdin
elif [[ -f "${default_log}" ]]; then
  input_source="${default_log}"
else
  error_missing_file "${default_log}"
fi

awk 'match($1,/^([0-9]{1,3}\.){3}[0-9]{1,3}$/){print $1}' "${input_source}" \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 20 \
  | awk '{print $2, $1}'
