
.PHONY: install uninstall

install:
	mkdir --parents "${HOME}/bin"
	cp src/gh-pages.sh "${HOME}/bin/gh-pages"
	chmod u+x "${HOME}/bin/gh-pages"
	mkdir --parents "${HOME}/.gh-pages"

uninstall:
	rm --force "${HOME}/bin/gh-pages"
	rm --recursive --force "${HOME}/.gh-pages"
