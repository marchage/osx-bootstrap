#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within

# _print_help()
if [[ "${1:-}" =~ ^-h|--help$ ]]; then
	_ME=$(basename "${0}")
	_V="v1.0.1"
	_ASCII_ME=$(figlet "$_ME")

	cat <<HEREDOC
${_ASCII_ME}
${_V}

Prints out the path of where it is located. Must be 
in the same directory or you should copy-past its code
into your own perhaps.

Usage:
  ${_ME}
  ${_ME} -h | --help

Options:
  -h --help  Show this screen.
HEREDOC
	exit 0
fi

pushd . >/dev/null || exit 80
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ -h "${SCRIPT_PATH}" ]; then
	while [ -h "${SCRIPT_PATH}" ]; do
		cd "$(dirname "$SCRIPT_PATH")" || exit 81
		SCRIPT_PATH=$(readlink "${SCRIPT_PATH}")
	done
fi
cd "$(dirname "${SCRIPT_PATH}")" >/dev/null || exit 82
SCRIPT_PATH=$(pwd)
# echo "$_SCRIPT_PATH"
popd >/dev/null || exit 83
