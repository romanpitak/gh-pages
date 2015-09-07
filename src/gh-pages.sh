#!/bin/bash
############################################################
#
#               gh-pages
#
# Author : Roman Piták <roman@pitak.net>
# License: MIT
#
#############################################################

set -eu

fail() {
    # Fail with a message and exit.
    echo "${1:-FAILED}" 1>&2
    exit 1
}

isGitRepo() {
    # Check if the current directory is a valid git repository.
    git status > /dev/null 2>&1
}

remoteHasGhPages() {
    # Check if origin has a branch called "gh-pages"
    git branch --list --remote | \
        grep --silent --regexp='^  origin/gh-pages$'
}

checkoutGhPages() {
    # Checkout the (existing) gh-pages branch from origin.
    git fetch origin gh-pages:refs/remotes/origin/gh-pages
    git checkout gh-pages
}

initGhPages() {
    # Initialize the "gh-pages" branch with an index.html file.
    git checkout --orphan gh-pages
    echo 'Let there be documentation!' > index.html
    git add index.html
    git ci -m 'first commit'
    git push origin gh-pages --set-upstream
}

initGitRepo() {
    # Create a git repo in the current directory and
    # - checkout the gh-pages branch
    # - or initialize the gh-pages branch.
    git init
    git remote add origin "${origin}"
    git fetch
    if remoteHasGhPages; then
        checkoutGhPages
    else
        initGhPages
    fi
    isGitRepo || fail 'Failed to create git repo.'
}

help() {
    echo '
NAME
    gh-pages - Synchronize documentation with GitHub pages.

SYNOPSIS
    gh-pages DIR          : publish contents of DIR to projects gh-pages
    gh-pages -h|--help    : display this help and exit

DESCRIPTION
    Push the project documentation (found in DIR) to the projects gh-pages
    branch. If the branch does not exist, it will be created.
    Commits format: "documentation update $(date '+%Y-%m-%d %H:%M:%S')"

OPTIONS:
    -h, --help            : display this help and exit

USAGE:
    make html && gh-pages html

    Implemented by Roman Piták <roman@pitak.net>
    Source available at https://github.com/romanpitak/gh-pages
'
}

main() {
    # rsync the given directory into the gh-pages branch
    # of the directorys git repository

    isGitRepo || fail "$(pwd) is not a Git repository."

    sourceDirectory="$(cd "${1}" && pwd)" \
        || fail "Could not access source directory \"${1}\""

    origin="$(git config --get remote.origin.url)" \
        || fail 'Remote "origin" not found.'
    destinationDirectory="$(echo "${origin}" | \
        sed -n -e 's/^git@github\.com:\(.*\)\.git$/\1/p')"
    test '' != "${destinationDirectory}" || fail 'Not a GitHub repo.'
    destinationDirectory="${HOME}/.gh-pages/${destinationDirectory}"

    mkdir -p "${destinationDirectory}"
    cd "${destinationDirectory}"
    isGitRepo || initGitRepo
    git pull

    rsync --archive --delete --exclude='.git' "${sourceDirectory}/" .
    git add --all
    git commit -m "documentation update $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin
}

# parse command line arguments
task='help'
while [[ $# > 0 ]]; do
    case "${1}" in
        -h|--help)
            help
            exit 0
            ;;
        *)
            task='main'
            sourcePath="${1}"
            ;;
    esac
    shift
done

case "${task}" in
    main)
        main "${sourcePath}"
        ;;
    help)
        help
        ;;
    *)
        fail 'Unexpected error. Please report this to roman@pitak.net'
        ;;
esac
