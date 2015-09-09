
INSTALL_PATH=# <<< configure
INVOCATION_COMMAND=# <<< configure

.PHONY: install uninstall

install:
	mkdir --parents "$(INSTALL_PATH)"
	cp src/gh-pages.sh "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"
	chmod u+x "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"
	mkdir --parents "${HOME}/.gh-pages"

uninstall:
	rm --force "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"
	rm --recursive --force "${HOME}/.gh-pages"
