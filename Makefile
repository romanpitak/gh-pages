###############################################################################
# Installation settings
###############################################################################
INSTALL_DIR=${HOME}/bin
INVOCATION_COMMAND=gh-pages

###############################################################################
# Build settings
###############################################################################
VERSION=0.3.1
BUILD_DIR=build

###############################################################################
# Dragons below
###############################################################################
SRC_DIR=src

EXEC_FILE=$(BUILD_DIR)/gh-pages.sh
DEST_FILE=$(INSTALL_DIR)/$(INVOCATION_COMMAND)

HTML_DIR=$(BUILD_DIR)/html
HTML_INDEX = $(HTML_DIR)/index.html

.PHONY: all clean docs push-docs install uninstall

all: $(EXEC_FILE)

$(BUILD_DIR):
	mkdir --parents "$@"

$(EXEC_FILE): $(SRC_DIR)/gh-pages.p.sh $(BUILD_DIR)
	preprocess --substitute \
		-D @VERSION@=$(VERSION) \
		-o $@ $<

clean:
	rm --recursive --force -- "$(BUILD_DIR)"

install: $(EXEC_FILE)
	install --mode=755 --no-target-directory -D "$<" "$(DEST_FILE)"

uninstall:
	rm --force -- "$(DEST_FILE)"

push-docs: $(HTML_INDEX)
	gh-pages --what-the-commit "$(HTML_DIR)"

$(HTML_DIR):
	mkdir --parents "$@"

$(HTML_INDEX): README.md docs/template.html $(HTML_DIR)
	pandoc \
		--smart \
		--tab-stop=4 \
		--ascii \
		--highlight-style=pygments \
		--table-of-contents --section-divs \
		--standalone --template=docs/template.html \
		--from=markdown_github \
		--to=html5 --output="$@" \
		README.md
