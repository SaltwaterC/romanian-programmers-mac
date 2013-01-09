#!/usr/bin/env bash

# the directory may not exist
sudo mkdir -p "/Library/Keyboard Layouts"

# removing the previous version
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.keylayout"
sudo rm -fv "/Library/Keyboard Layouts/Romanian Programmers Mac.icns"

# install / update the current version
echo "Installing Romanian - Programmers.icns"
sudo curl --silent "" --output "/Library/Keyboard Layouts/Romanian - Programmers.icns"
echo "Installing Romanian - Programmers.keylayout"
sudo curl --silent "" --output "/Library/Keyboard Layouts/Romanian - Programmers.keylayout"

# clear the OS intl caches
sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | xargs rm -v

# in case of update ...
echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile dupa actualizare, este nevoie de logout + login\033[0m"
