#!/usr/bin/env bash

set -euo pipefail

usage() {
	echo "Utilizare: $0 [--user|--system]"
	echo
	echo "  --user      dezinstalează doar pentru utilizatorul curent, fără sudo (implicit)"
	echo "  --system    dezinstalează instalarea pentru toți utilizatorii, folosind sudo"
}

uninstall_scope="user"

for argument in "$@"
do
	case "${argument}" in
		--user|user)
			uninstall_scope="user"
			;;
		--system|system)
			uninstall_scope="system"
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Argument necunoscut: ${argument}" >&2
			usage >&2
			exit 1
			;;
	esac
done

if [ "$(id -u)" -eq 0 ]
then
	echo "Nu rula scriptul cu sudo; varianta --system cere sudo doar pentru ștergerea fișierelor." >&2
	exit 1
fi

if [ "${uninstall_scope}" = "user" ]
then
	install_dir="${HOME}/Library/Keyboard Layouts"
else
	install_dir="/Library/Keyboard Layouts"
fi

run_privileged() {
	if [ "${uninstall_scope}" = "system" ]
	then
		sudo "$@"
	else
		"$@"
	fi
}

remove_file() {
	local path="$1"
	if [ -e "${path}" ] || [ -L "${path}" ]
	then
		run_privileged rm -fv "${path}"
	fi
}

remove_bundle() {
	local path="$1"
	if [ -d "${path}" ] || [ -L "${path}" ]
	then
		run_privileged rm -rf "${path}"
	fi
}

echo "» Dezinstalez Romanian - Programmers din ${install_dir}"

# Remove the old loose-layout names as well as the current bundle, so this
# also cleans installations made by older versions of install.sh.
remove_file "${install_dir}/Romanian Programmers Mac.keylayout"
remove_file "${install_dir}/Romanian Programmers Mac.icns"
remove_file "${install_dir}/Romanian - Programmers.keylayout"
remove_file "${install_dir}/Romanian - Programmers.icns"
remove_bundle "${install_dir}/Romanian - Programmers.bundle"

echo "» Reîncarc meniul de input"
killall TextInputMenuAgent TextInputSwitcher PAH_Extension 2>/dev/null || true

if [ "${uninstall_scope}" = "user" ]
then
	echo -e "\n\033[1mDezinstalarea per-user este finalizată. Dacă Input Sources era deschis, închide-l și redeschide-l.\033[0m"
else
	echo -e "\n\033[1mFișierele system-wide au fost eliminate.\033[0m"
fi
