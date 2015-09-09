
INSTALL_PATH=# <<< configure
INVOCATION_COMMAND=# <<< configure
VERSION=# <<< configure

.PHONY: all clean install uninstall

gh-pages.sh: src/gh-pages.sh
	./configure \
		--silent \
		--variable-VERSION="$(VERSION)" \
		--preprocessor-suffix=' # <<< configure' \
		--in-file="$<" \
		--out-file="$@"
	chmod a+x gh-pages.sh

all: gh-pages.sh

clean:
	rm --force 'gh-pages.sh'

install: gh-pages.sh
	mkdir --parents "$(INSTALL_PATH)"
	cp "$<" "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"
	mkdir --parents "${HOME}/.gh-pages"

uninstall:
	rm --force "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"
	rm --recursive --force "${HOME}/.gh-pages"
