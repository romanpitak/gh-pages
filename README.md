# gh-pages

**Synchronize documentation with GitHub pages.**

## Usage

```bash
gh-pages html
```

Where `html` is the directory containing the html documentation files.

A `Makefile` target example:

```make
gh-pages: html_dir
    gh-pages --force $<
```

## Synopsis

    gh-pages [OPTION]... DIR   : publish contents of DIR to projects gh-pages
    gh-pages -h|--help         : display this help and exit
    gh-pages --version         : print version and exit

## Description

Push the project documentation (found in DIR) to the projects gh-pages
branch. If the branch does not exist, it will be created.
Commits format: "documentation update $(date '+%Y-%m-%d %H:%M:%S')"

## Options

    --force                    : assume yes on all prompts
    -h, --help                 : display this help and exit
    --verbose                  : explain what is being done
    --version                  : print version and exit

## Installation

```bash
git clone git@github.com:romanpitak/gh-pages.git
cd gh-pages
./configure && make && make install
```

By default, the install script copies the `gh-pages` executable to `~/bin`.
On first run, the script creates the `~/.gh-pages` directory to store
the checked out branches.

You can change the installation directory and the command name
by running `./configure`
with options `--install-path` or `--invocation-command`.
For more configuration info run `./configure --help`.

**Pro tip:** `make --dry-run` will show you what will be done. 

### Uninstall

```bash
make uninstall
rm -rf ~/.gh-pages  # to delete the data
```
