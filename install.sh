#!/usr/bin/env bash

set -euo pipefail

usage() {
	echo "Utilizare: $0 [local|remote] [--user|--system]"
	echo
	echo "  local       folosește fișierele din depozitul curent"
	echo "  remote      descarcă fișierele din GitHub (implicit)"
	echo "  --user      instalează doar pentru utilizatorul curent, fără sudo (implicit)"
	echo "  --system    instalează pentru toți utilizatorii, folosind sudo"
}

source_mode="remote"
install_scope="user"
layout_variant=""
layout_version=""
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for argument in "$@"
do
	case "${argument}" in
		local)
			source_mode="local"
			;;
		remote)
			source_mode="remote"
			;;
		--user|user)
			install_scope="user"
			;;
		--system|system)
			install_scope="system"
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
	echo "Nu rula scriptul cu sudo; varianta --system cere sudo doar pentru copierea fișierelor." >&2
	exit 1
fi

if [ "${install_scope}" = "user" ]
then
	install_dir="${HOME}/Library/Keyboard Layouts"
else
	install_dir="/Library/Keyboard Layouts"
fi

run_privileged() {
	if [ "${install_scope}" = "system" ]
	then
		sudo "$@"
	else
		"$@"
	fi
}

# make the users aware that there are multiple layouts
echo "Trebuie sa alegi aranjamentul potrivit pentru tastatura ta."
echo
echo "Aranjamentele mapeaza tasta \"\` si ~\" in pozitia uzuala, inainte de tasta 1."
echo "Apple furnizeaza cel putin 3 aranjamente diferite din punct de vedere vizual."
echo "Acele aranjamente sunt de fapt vreo doua din punct de vedere functional."
echo
echo "» Primul aranjament are tasta inscriptionata cu \"\` si ~\" inainte de 1"
echo "» Al doilea aranjament are tasta inscriptionata cu \"§ si ±\" inainte de 1"
echo
echo "Cel de-al doilea aranjament se poate intalni si in cazul tastaturilor care"
echo "au inscriptionate diacritice pentru limba Romana fabricate de Apple, dar "
echo "nu in pozitiile definite de SR 13392:2004. Acest tip de aranjament are o "
echo "tasta suplimentara intre Shift si Z."
echo
PS3="Alege varianta layout-ului: "
select layout_choice in \
	"standard" \
	"non-standard/uk (Option + G produce £)" \
	"non-standard/de (Shift + Option + W produce ẞ)"
do
	case "${REPLY}" in
		1)
			layout_variant="standard"
			layout_description="standard"
			break
			;;
		2)
			layout_variant="uk"
			layout_description="non-standard/uk"
			break
			;;
		3)
			layout_variant="de"
			layout_description="non-standard/de"
			break
			;;
		*)
			echo "Alegere invalidă. Tastează 1, 2 sau 3." >&2
			;;
	esac
done

PS3="Alege varianta fizică a tastaturii: "
select layout_version in "1" "2"
do
	case "${REPLY}" in
		1|2)
			break
			;;
		*)
			echo "Alegere invalidă. Tastează 1 sau 2." >&2
			;;
	esac
done

if [ "${layout_variant}" = "uk" ]
then
	layout_file="Romanian - Programmers non-standard UK ${layout_version}.keylayout"
elif [ "${layout_variant}" = "de" ]
then
	layout_file="Romanian - Programmers non-standard DE ${layout_version}.keylayout"
else
	layout_file="Romanian - Programmers ${layout_version}.keylayout"
fi

# macOS 12.4 replaced the system input-source flags with language-code icons.
# Use a matching RO icon on newer releases and keep the Romanian flag for older
# releases, where the flag is the native visual convention.
macos_version="$(sw_vers -productVersion 2>/dev/null || true)"
macos_major="${macos_version%%.*}"
macos_minor="${macos_version#*.}"
macos_minor="${macos_minor%%.*}"
legacy_icon=0
if [ -n "${macos_major}" ] && { [ "${macos_major}" -lt 12 ] || { [ "${macos_major}" -eq 12 ] && [ "${macos_minor}" -lt 4 ]; }; }
then
	legacy_icon=1
fi

staging_dir="$(mktemp -d)"
bundle_dir="${staging_dir}/Romanian - Programmers.bundle/Contents"
resource_dir="${bundle_dir}/Resources"
mkdir -p "${resource_dir}"
trap 'rm -rf "${staging_dir}"' EXIT

# Install / update the current version. Build the replacement in a temporary
# directory first, so a failed download does not remove a working installation.
if [ "${source_mode}" = "local" ]
then
	echo "» Instalez Romanian - Programmers folosind depozitul curent"
	cp "${script_dir}/Romanian - Programmers Info.plist" "${bundle_dir}/Info.plist"
	cp "${script_dir}/${layout_file}" \
		"${resource_dir}/Romanian - Programmers.keylayout"
	if [ "${legacy_icon}" -eq 1 ]
	then
		echo "» Instalez iconița steag pentru macOS anterior lui 12.4"
		cp "${script_dir}/Romanian - Programmers Flag.icns" \
			"${resource_dir}/Romanian - Programmers.icns"
	else
		echo "» Instalez iconița RO pentru macOS 12.4+"
		cp "${script_dir}/Romanian - Programmers RO.icns" \
			"${resource_dir}/Romanian - Programmers.icns"
	fi
else
	echo "» Instalez Romanian - Programmers folosind GitHub"
	curl --fail --silent --show-error --location --max-redirs 10 \
		"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20Info.plist" \
		--output "${bundle_dir}/Info.plist"
	echo "» Instalez ${layout_file} (${layout_description})"
	curl --fail --silent --show-error --location --max-redirs 10 \
		"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/${layout_file// /%20}" \
		--output "${resource_dir}/Romanian - Programmers.keylayout"
	if [ "${legacy_icon}" -eq 1 ]
	then
		echo "» Instalez iconița steag pentru macOS anterior lui 12.4"
		curl --fail --silent --show-error --location --max-redirs 10 \
			"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20Flag.icns" \
			--output "${resource_dir}/Romanian - Programmers.icns"
	else
		echo "» Instalez iconița RO pentru macOS 12.4+"
		curl --fail --silent --show-error --location --max-redirs 10 \
			"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20RO.icns" \
			--output "${resource_dir}/Romanian - Programmers.icns"
	fi
fi

# The modern RO icon is a template so macOS can adapt its foreground/background
# colours in the menu bar. Keep the legacy flag untouched on older releases.
if [ "${legacy_icon}" -eq 0 ]
then
	/usr/bin/plutil -insert 'KLInfo_Romanian - Programmers.TISIconIsTemplate' \
		-bool true "${bundle_dir}/Info.plist"
fi

# The bundle metadata is what makes macOS list the layout under Romanian
# instead of Others. Remove old loose layouts and the previous bundle only
# after the replacement bundle has been prepared successfully.
run_privileged mkdir -p "${install_dir}"
run_privileged rm -fv "${install_dir}/Romanian Programmers Mac.keylayout"
run_privileged rm -fv "${install_dir}/Romanian Programmers Mac.icns"
run_privileged rm -fv "${install_dir}/Romanian - Programmers.keylayout"
run_privileged rm -fv "${install_dir}/Romanian - Programmers.icns"
run_privileged rm -rf "${install_dir}/Romanian - Programmers.bundle"

echo "» Instalez bundle-ul Romanian - Programmers în ${install_dir}"
run_privileged cp -R "${staging_dir}/Romanian - Programmers.bundle" \
	"${install_dir}/"

# The menu-bar input source is cached by per-user agents separately from the
# Keyboard Layouts view. Restart them so an updated icon is picked up without
# requiring a full reboot. They are relaunched automatically by macOS.
echo "» Reîncarc meniul de input"
killall TextInputMenuAgent TextInputSwitcher PAH_Extension 2>/dev/null || true

if [ "${install_scope}" = "user" ]
then
	echo -e "\n\033[1mBundle-ul a fost instalat pentru utilizatorul curent. Adaugă Romanian - Programmers din System Settings > Keyboard > Input Sources.\033[0m"
else
	echo -e "\n\033[1mBundle-ul a fost instalat system-wide. Fiecare utilizator îl poate adăuga din propriile Input Sources.\033[0m"
fi
