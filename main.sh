#!/usr/bin/env bash
set -euo pipefail

log_file="${1:-access.log}"

if [[ ! -f "${log_file}" ]]; then
  printf 'Error: log file not found: %s\n' "${log_file}" >&2
  exit 1
fi

awk 'match($1,/^([0-9]{1,3}\.){3}[0-9]{1,3}$/){print $1}' "${log_file}" \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 20 \
  | awk '{print $2, $1}'
