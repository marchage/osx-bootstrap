#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

function fail {
  echo "$1" >&2
  exit 1
}

function retry {
  local n=1
  local max=5
  local delay=3
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}
