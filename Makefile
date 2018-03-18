.PHONY: all
.DEFAULT: all

all:
	@sed 's/code="10"/code="swap"/g; s/code="50"/code="10"/g; s/code="swap"/code="50"/g' 'Romanian - Programmers 2.keylayout' > 'Romanian - Programmers 1.keylayout'
