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

## Description

Push the project documentation (found in DIR) to the projects gh-pages
branch. If the branch does not exist, it will be created.
Commits format: "documentation update $(date '+%Y-%m-%d %H:%M:%S')"

## Options

    --force                    : assume yes on all prompts
    -h, --help                 : display this help and exit
    --verbose                  : explain what is being done

## Installation

```bash
git clone git@github.com:romanpitak/gh-pages.git
cd gh-pages
make install
```

The install script copies the `gh-pages` executable to `~/bin`
and creates a directory `~/.gh-pages` to store the documentation branches.

### Uninstall

```bash
make uninstall
```
