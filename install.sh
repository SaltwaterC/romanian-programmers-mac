#!/usr/bin/env bash

update=0

if [ ! -d ~/.romanian-programmers-mac ]
then
	git clone git://github.com/SaltwaterC/romanian-programmers-mac.git ~/.romanian-programmers-mac
	cd ~/.romanian-programmers-mac
else
	cd ~/.romanian-programmers-mac
	git reset --hard HEAD
	git pull origin master
	update=1
fi

sudo mkdir -p "/Library/Keyboard Layouts"

sudo cp -v "Romanian Programmers Mac.keylayout" "/Library/Keyboard Layouts"
sudo cp -v "Romanian Programmers Mac.icns" "/Library/Keyboard Layouts"

sudo find /System/Library/Caches -name "*IntlDataCache*" 2>/dev/null | xargs rm -v
sudo find /var -name "*IntlDataCache*" 2>/dev/null | xargs rm -v

if [ $update -eq 1 ]
then
	echo -e "\n\033[1mAtentie: pentru ca schimbarile sa fie vizibile, este nevoie de logout + login\033[0m"
fi
