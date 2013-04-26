#!/usr/bin/env bash

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
	echo "» Instalez Romanian - Programmers.keylayout"
	sudo cp "Romanian - Programmers.keylayout" "/Library/Keyboard Layouts/"
else
	echo "» Instalez Romanian - Programmers folosind GitHub"
	echo "» Instalez Romanian - Programmers.icns"
	sudo curl --silent "https://raw.github.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.icns" --output "/Library/Keyboard Layouts/Romanian - Programmers.icns"
	echo "» Instalez Romanian - Programmers.keylayout"
	sudo curl --silent "https://raw.github.com/SaltwaterC/romanian-programmers-mac/master/Romanian%20-%20Programmers.keylayout" --output "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"
fi

# clear the OS intl caches
sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | sudo xargs rm -v

# in case of update ...
echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile dupa actualizare, este nevoie de logout + login\033[0m"
