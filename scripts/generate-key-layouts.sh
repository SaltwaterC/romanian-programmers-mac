#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "${script_dir}/.." && pwd)"
source_file="${project_dir}/Romanian - Programmers 2.keylayout"
standard_layout_one="${project_dir}/Romanian - Programmers 1.keylayout"
uk_layout_two="${project_dir}/Romanian - Programmers non-standard UK 2.keylayout"
uk_layout_one="${project_dir}/Romanian - Programmers non-standard UK 1.keylayout"
de_layout_two="${project_dir}/Romanian - Programmers non-standard DE 2.keylayout"
de_layout_one="${project_dir}/Romanian - Programmers non-standard DE 1.keylayout"

usage() {
	echo "Utilizare: $0"
	echo
	echo "Generează toate layout-urile derivate din Romanian - Programmers 2.keylayout."
}

if [ "$#" -gt 0 ]
then
	case "$1" in
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Argumente necunoscute: $*" >&2
			usage >&2
			exit 1
			;;
	esac
fi

if [ ! -f "${source_file}" ]
then
	echo "Fișierul sursă lipsește: ${source_file}" >&2
	exit 1
fi

temporary_dir="$(mktemp -d)"
trap 'rm -rf "${temporary_dir}"' EXIT

swap_layout_one_codes() {
	sed 's/code="10"/code="swap"/g; s/code="50"/code="10"/g; s/code="swap"/code="50"/g' "$1"
}

generate_uk_layout() {
	awk '
		/<keyMap index="/ {
			uk_map = ($0 ~ /index="2"/ || $0 ~ /index="4"/ || $0 ~ /index="7"/ || $0 ~ /index="8"/)
		}
		uk_map && /<key code="5" output="g"\/>/ {
			sub(/output="g"/, "output=\"£\"")
		}
		uk_map && /<key code="5" output="G"\/>/ {
			sub(/output="G"/, "output=\"£\"")
		}
		{ print }
		/<\/keyMap>/ { uk_map = 0 }
	' "$1"
}

generate_de_layout() {
	awk '
		/<keyMap index="/ {
			de_map = ($0 ~ /index="4"/ || $0 ~ /index="8"/)
		}
		de_map && /<key code="13" output=""\/>/ {
			sub(/output=""/, "output=\"ẞ\"")
		}
		{ print }
		/<\/keyMap>/ { de_map = 0 }
	' "$1"
}

swap_layout_one_codes "${source_file}" > "${temporary_dir}/standard-1.keylayout"
generate_uk_layout "${source_file}" > "${temporary_dir}/uk-2.keylayout"
swap_layout_one_codes "${temporary_dir}/uk-2.keylayout" > "${temporary_dir}/uk-1.keylayout"
generate_de_layout "${source_file}" > "${temporary_dir}/de-2.keylayout"
swap_layout_one_codes "${temporary_dir}/de-2.keylayout" > "${temporary_dir}/de-1.keylayout"

cp "${temporary_dir}/standard-1.keylayout" "${standard_layout_one}"
cp "${temporary_dir}/uk-2.keylayout" "${uk_layout_two}"
cp "${temporary_dir}/uk-1.keylayout" "${uk_layout_one}"
cp "${temporary_dir}/de-2.keylayout" "${de_layout_two}"
cp "${temporary_dir}/de-1.keylayout" "${de_layout_one}"
