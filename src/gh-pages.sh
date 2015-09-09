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

VERSION=0.0.0 # <<< configure

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
    echo '>>> Looking for gh-pages on remote...'
    git branch --list --remote | \
        grep --silent --regexp='^  origin/gh-pages$'
}

checkoutGhPages() {
    # Checkout the (existing) gh-pages branch from origin.
    echo '>>> Checking out gh-pages from remote...'
    git fetch origin gh-pages:refs/remotes/origin/gh-pages
    git checkout gh-pages 2>&1
}

initGhPages() {
    # Initialize the "gh-pages" branch with an index.html file.
    echo '>>> Creating a new gh-pagex branch...'
    git checkout --orphan gh-pages 2>&1
    echo 'Let there be documentation!' > index.html
    git add index.html
    git ci -m 'first commit'
    git push origin gh-pages --set-upstream 2>&1
}

initGitRepo() {
    # Create a git repo in the current directory and
    # - checkout the gh-pages branch
    # - or initialize the gh-pages branch.
    echo '>>> Initiating local clone...'
    git init
    git remote add origin "${origin}"
    git fetch 2>&1
    if remoteHasGhPages; then
        checkoutGhPages
    else
        initGhPages
    fi
    isGitRepo || fail 'Failed to create git repo.'
}

commitAndPush() {
    echo '>>> pushing the changes...'
    git commit -m "documentation update $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin 2>&1
    echo '>>> DONE'
}

help() {
    echo '
NAME
    gh-pages - Synchronize documentation with GitHub pages.

SYNOPSIS
    gh-pages [OPTION]... DIR   : publish contents of DIR to projects gh-pages
    gh-pages -h|--help         : display this help and exit
    gh-pages --version         : print version and exit

DESCRIPTION
    Push the project documentation (found in DIR) to the projects gh-pages
    branch. If the branch does not exist, it will be created.
    Commits format: "documentation update $(date '+%Y-%m-%d %H:%M:%S')"

OPTIONS:
    --force                    : assume yes on all prompts
    -h, --help                 : display this help and exit
    --verbose                  : explain what is being done
    --version                  : print version and exit

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
    isGitRepo || initGitRepo >> "${verboseOutput}"
    git pull >> "${verboseOutput}"

    rsync --archive --delete --exclude='.git' "${sourceDirectory}/" .
    git add --all

    # Check if anything actually changed and exit if not.
    if test 0 == "$(git status --short | wc --lines)"; then
        message='>>> gh-pages up-to-date. Nothing to be done.'
        echo "${message}" >> "${verboseOutput}"
        exit 0
    fi

    if test True == "${force}"; then
        commitAndPush >> "${verboseOutput}"
    else
        echo '========== Files to be commited =========='
        git status --short
        # -p prompt
        # -n read returns after reading nchars characters
        # -r backslash does not act as an escape character
        read -p 'Are you sure you want to commit the changes? [y] ' -n 1 -r
        echo
        case "${REPLY}" in
            y|Y|'')
                commitAndPush >> "${verboseOutput}"
                ;;
            *)
                echo 'Aborting!'
                git reset --hard
                ;;
        esac
    fi
}

# parse command line arguments
task='help'
force=False
verboseOutput='/dev/null'
while [[ $# > 0 ]]; do
    case "${1}" in
        -h|--help)
            help
            exit 0
            ;;
        --force)
            force=True
            ;;
        --verbose)
            verboseOutput='/dev/stdout'
            ;;
        --version)
            echo "${VERSION}"
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
