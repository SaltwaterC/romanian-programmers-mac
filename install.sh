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
echo "Al treilea aranjament schimba intre ele tastele \"§± cu \`~\" pentru "
echo "pentru tastaturile cu \"§ si ±\" inainte de 1"
echo
read -p "Alege varianta aranjamentului (1 sau 2 sau 3) : " layout

if [ "${layout}" != "1" ] && [ "${layout}" != "2" ] && [ "${layout}" != "3" ]
then
	echo "Aranjamentul ales este invalid. Valori acceptate: 1, 2 sau 3."
	exit 1
fi

# the directory may not exist
sudo mkdir -p "/Library/Keyboard Layouts"

# removing the previous version
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.icns"

# install / update the current version
if [ "$1" == "local" ]
then
	echo "» Instalez Romanian - Programmers folosind depozitul curent"
	echo "» Instalez Romanian - Programmers.icns"
	sudo cp "Romanian - Programmers.icns" "/Library/Keyboard Layouts/"
	echo "» Instalez Romanian - Programmers ${layout}.keylayout"
	sudo cp "Romanian - Programmers ${layout}.keylayout" \
"/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
else
	echo "» Instalez Romanian - Programmers folosind GitHub"
	echo "» Instalez Romanian - Programmers.icns"
	sudo curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.icns" \
--output "/Library/Keyboard Layouts/Romanian - Programmers.icns"
	echo "» Instalez Romanian - Programmers ${layout}.keylayout"
	sudo curl --silent --location --max-redirs 10 \
"https://raw.githubusercontent.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers%20${layout}.keylayout" \
--output "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
fi

# clear the OS intl caches
sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v

# in case of update ...
echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile dupa actualizare, este nevoie de logout + login\033[0m"
