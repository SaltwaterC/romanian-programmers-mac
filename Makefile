.PHONY: all bundle icons install install-user install-system uninstall uninstall-user uninstall-system reinstall
.DEFAULT: all

all:
	@sed 's/code="10"/code="swap"/g; s/code="50"/code="10"/g; s/code="swap"/code="50"/g' 'Romanian - Programmers 2.keylayout' > 'Romanian - Programmers 1.keylayout'

icons:
	@swift scripts/generate-language-icon.swift 'Romanian - Programmers RO.icns' 1024 language-code
	@swift scripts/generate-language-icon.swift 'Romanian - Programmers Flag.icns' 1024 romanian-flag

bundle: all
	@mkdir -p 'Romanian - Programmers.bundle/Contents/Resources'
	@cp 'Romanian - Programmers Info.plist' 'Romanian - Programmers.bundle/Contents/Info.plist'
	@/usr/bin/plutil -insert 'KLInfo_Romanian - Programmers.TISIconIsTemplate' -bool true 'Romanian - Programmers.bundle/Contents/Info.plist'
	@cp 'Romanian - Programmers 2.keylayout' 'Romanian - Programmers.bundle/Contents/Resources/Romanian - Programmers.keylayout'
	@cp 'Romanian - Programmers RO.icns' 'Romanian - Programmers.bundle/Contents/Resources/Romanian - Programmers.icns'

# The default developer workflow is per-user and does not require sudo.
install: install-user

install-user: all
	@./install.sh local --user

install-system: all
	@./install.sh local --system

uninstall: uninstall-user

uninstall-user:
	@./uninstall.sh --user

uninstall-system:
	@./uninstall.sh --system

reinstall: uninstall-user install-user
