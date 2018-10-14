#!/usr/bin/env bash

# _print_help()
if [[ "${1:-}" =~ ^-h|--help$ ]]; then
	_ME=$(basename "${0}")
	_V="v1.0.1"
	_ASCII_ME=$(figlet "$_ME")

	cat <<HEREDOC
${_ASCII_ME}
${_V}

Prints out the relative path between paths. These paths can be absolute 
as well as relative or even non-existant. Trivial (to make), according 
to its author. Path 1 needs to be more shallow than path 2. The otherway
around does not (always) work.

Usage:
  ${_ME} <path_1> <path_2>
  ${_ME} -h | --help

Options:
  -h --help  Show this screen.
HEREDOC
	exit 0
fi

# Prints out the relative path between two absolute paths. Trivial,
# according to the author
#
# Parameters:
# $1 = first path
# $2 = second path
#
# Output: the relative path between 1st and 2nd paths
pos="${1%%/}"
ref="${2%%/}"
down=''

while :; do
	test "$pos" = '/' && break
	case "$ref" in $pos/*) break ;; esac
	down="../$down"
	pos=${pos%/*}
done

echo "$down${ref##$pos/}"
