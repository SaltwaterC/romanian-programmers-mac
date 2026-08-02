#!/usr/bin/env bash

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
read -p "Alege varianta aranjamentului (1 sau 2): " layout

if [ "${layout}" != "1" ] && [ "${layout}" != "2" ]
then
	echo "Aranjamentul ales este invalid. Valori acceptate: 1 sau 2."
	exit 1
fi

# the directory may not exist
sudo mkdir -p "/Library/Keyboard Layouts"

# Remove the old loose layout and any previous bundle. The bundle metadata is
# what makes macOS list the layout under Romanian instead of Others.
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.icns"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian - Programmers.icns"
sudo rm -rf "/Library/Keyboard Layouts/Romanian - Programmers.bundle"

staging_dir="$(mktemp -d)"
bundle_dir="${staging_dir}/Romanian - Programmers.bundle/Contents"
resource_dir="${bundle_dir}/Resources"
mkdir -p "${resource_dir}"
trap 'rm -rf "${staging_dir}"' EXIT

# install / update the current version
if [ "$1" == "local" ]
then
	echo "» Instalez Romanian - Programmers folosind depozitul curent"
	cp "Romanian - Programmers.bundle/Contents/Info.plist" "${bundle_dir}/Info.plist"
	cp "Romanian - Programmers.icns" \
"${resource_dir}/Romanian - Programmers.icns"
	cp "Romanian - Programmers ${layout}.keylayout" \
"${resource_dir}/Romanian - Programmers.keylayout"
else
	echo "» Instalez Romanian - Programmers folosind GitHub"
	curl --fail --silent --show-error --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.bundle/Contents/Info.plist" \
--output "${bundle_dir}/Info.plist"
	curl --fail --silent --show-error --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.icns" \
	--output "${resource_dir}/Romanian - Programmers.icns"
	echo "» Instalez Romanian - Programmers ${layout}.keylayout"
	curl --fail --silent --show-error --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20${layout}.keylayout" \
	--output "${resource_dir}/Romanian - Programmers.keylayout"
fi

echo "» Instalez bundle-ul Romanian - Programmers"
sudo cp -R "${staging_dir}/Romanian - Programmers.bundle" \
"/Library/Keyboard Layouts/"

# clear the OS intl caches
sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v

# in case of update ...
echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile dupa actualizare, este nevoie de logout + login\033[0m"
