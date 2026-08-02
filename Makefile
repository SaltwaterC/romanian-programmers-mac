.PHONY: all bundle
.DEFAULT: all

all:
	@sed 's/code="10"/code="swap"/g; s/code="50"/code="10"/g; s/code="swap"/code="50"/g' 'Romanian - Programmers 2.keylayout' > 'Romanian - Programmers 1.keylayout'

bundle: all
	@mkdir -p 'Romanian - Programmers.bundle/Contents/Resources'
	@cp 'Romanian - Programmers Info.plist' 'Romanian - Programmers.bundle/Contents/Info.plist'
	@/usr/bin/plutil -insert 'KLInfo_Romanian - Programmers.TISIconIsTemplate' -bool true 'Romanian - Programmers.bundle/Contents/Info.plist'
	@cp 'Romanian - Programmers 2.keylayout' 'Romanian - Programmers.bundle/Contents/Resources/Romanian - Programmers.keylayout'
	@cp 'Romanian - Programmers RO.icns' 'Romanian - Programmers.bundle/Contents/Resources/Romanian - Programmers.icns'
