
INSTALL_PATH=${HOME}/bin# <<< configure
INVOCATION_COMMAND=gh-pages# <<< configure
VERSION=0.0.0# <<< configure

.PHONY: all clean gh-pages install uninstall

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
	rm --recursive --force "$(HTML_DIR)"

install: gh-pages.sh
	mkdir --parents "$(INSTALL_PATH)"
	cp "$<" "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"

uninstall:
	rm --force "$(INSTALL_PATH)/$(INVOCATION_COMMAND)"

# DOCUMENTATION

HTML_DIR = html
HTML_INDEX = $(HTML_DIR)/index.html
HTML_SOURCE = https://github.com/romanpitak/gh-pages

$(HTML_INDEX): *
	mkdir --parents "$(HTML_DIR)"
	tree -H ./ > "$(HTML_INDEX)"

gh-pages: $(HTML_INDEX)
	gh-pages "$(HTML_DIR)"
