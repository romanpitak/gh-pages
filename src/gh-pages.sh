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

###############################################################################
# Fail with a message and exit.
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   message || None
# Returns:
#   None
###############################################################################
function ghp::fail() {
    printf '%s\n' "${1:-FAILED}" 1>&2
    exit 1
}

###############################################################################
# Check if the current directory is a valid git repository.
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::is_git_repo() {
    git status > /dev/null 2>&1
}

###############################################################################
# Check if origin has a branch called "gh-pages".
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::remote_has_gh_pages() {
    printf '%s\n' '>>> Looking for gh-pages on remote...'
    git branch --list --remote \
        | grep --silent --regexp='^  origin/gh-pages$'
}

###############################################################################
# Checkout the (existing) gh-pages branch from origin.
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::checkout_gh_pages() {
    printf '%s\n' '>>> Checking out gh-pages from remote...'
    git fetch origin gh-pages:refs/remotes/origin/gh-pages
    git checkout gh-pages 2>&1
}

###############################################################################
# Initialize new "gh-pages" branch with an index.html file.
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::init_gh_pages() {
    printf '%s\n' '>>> Creating a new gh-pagex branch...'
    git checkout --orphan gh-pages 2>&1
    printf '%s\n' 'Let there be documentation!' > index.html
    git add index.html
    git ci -m 'first commit'
    git push origin gh-pages --set-upstream 2>&1
}

###############################################################################
# Create a git repo in the current directory and
# - checkout the gh-pages branch
# - or initialize the gh-pages branch.
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::init_git_repo() {
    printf '%s\n' '>>> Initiating local clone...'
    git init
    git remote add origin "${origin}"
    git fetch 2>&1
    if ghp::remote_has_gh_pages; then
        ghp::checkout_gh_pages
    else
        ghp::init_gh_pages
    fi
    ghp::is_git_repo || fail 'Failed to create git repo.'
}

###############################################################################
# Commit the current changes and push
#
# Globals:
#   commit_message
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::commit_and_push() {
    printf '%s\n' '>>> pushing the changes...'
    local message
    if test -n "${commit_message:-}"; then
        message="${commit_message}"
    else
        message="documentation update $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    git commit -m "${message}"
    git push origin 2>&1
    printf '%s\n' '>>> DONE'
}

###############################################################################
# Print help
#
# Globals:
#   None
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::help() {
    printf '%s\n' '
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
    -m, --message  <msg>       : specify the commit message
    --verbose                  : explain what is being done
    --version                  : print version and exit
    --what-the-commit          : use http://whatthecommit.com/

USAGE:
    make html && gh-pages html

    Implemented by Roman Piták <roman@pitak.net>
    Source available at https://github.com/romanpitak/gh-pages
'
}

###############################################################################
# rsync the given directory into the gh-pages branch
# of the directorys git repository
#
# Globals:
#   source_path
#   force
#   verbose_output
# Calls:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
function ghp::main() {

    ghp::is_git_repo || fail "$(pwd) is not a Git repository."

    local source_directory="$(cd "${1}" && pwd)" \
        || ghp::fail "Could not access source directory \"${1}\""

    local origin="$(git config --get remote.origin.url)" \
        || ghp::fail 'Remote "origin" not found.'
    local destination_directory="$(printf '%s\n' "${origin}" | \
        sed -n -e 's/^git@github\.com:\(.*\)\.git$/\1/p')"
    test -n "${destination_directory}" \
        || ghp::fail 'Not a GitHub repo.'
    destination_directory="${HOME}/.gh-pages/${destination_directory}"

    mkdir -p "${destination_directory}"
    cd "${destination_directory}"
    ghp::is_git_repo || ghp::init_git_repo >> "${verbose_output}"
    git pull >> "${verbose_output}"

    rsync --archive --delete --exclude='.git' "${source_directory}/" .
    git add --all

    # Check if anything actually changed and exit if not.
    if test 0 == "$(git status --short | wc --lines)"; then
        printf '%s\n' '>>> gh-pages up-to-date. Nothing to be done.' \
            >> "${verbose_output}"
        exit 0
    fi

    if test True == "${force}"; then
        ghp::commit_and_push >> "${verbose_output}"
    else
        printf '%s\n' '========== Files to be commited =========='
        git status --short
        # -p prompt
        # -n read returns after reading nchars characters
        # -r backslash does not act as an escape character
        read -p 'Are you sure you want to commit the changes? [y] ' -n 1 -r
        printf '\n'
        case "${REPLY}" in
            y|Y|'')
                ghp::commit_and_push >> "${verbose_output}"
                ;;
            *)
                printf '%s\n' 'Aborting!'
                git reset --hard
                ;;
        esac
    fi
}

###############################################################################
#                     command line arguments processing
###############################################################################

force=False
verbose_output='/dev/null'
while [[ $# > 0 ]]; do
    case "${1}" in
        -h|--help)
            ghp::help
            exit 0
            ;;
        --force)
            force=True
            ;;
        -m|--message)
            commit_message="${2:-}"
            test -n "${commit_message}" \
                || ghp::fail 'You need to specify a commit message.'
            shift
            ;;
        --verbose)
            verbose_output='/dev/stdout'
            ;;
        --version)
            printf '%s\n' "${VERSION}"
            exit 0
            ;;
        --what-the-commit)
            if command -v 'curl' >/dev/null 2>&1; then
                commit_message="$(
                    curl \
                        --silent \
                        'http://whatthecommit.com/index.txt'
                    )"
            elif command -v 'wget' >/dev/null 2>&1; then
                commit_message="$(
                    wget \
                        --quiet \
                        --output-document=- \
                        'http://whatthecommit.com/index.txt'\
                    )"
            else
                ghp::fail 'You need curl or wget to use --what-the-commit'
            fi
            ;;
        *)
            if test ! -d "${1}"; then
                ghp::help
                ghp::fail 'Not a directory.'
            fi
            source_path="${1}"
            ;;
    esac
    shift
done

###############################################################################
#                                 main
###############################################################################

if test -z "${source_path:-}"; then
    ghp::help
    ghp::fail 'Content directory not specified.'
fi

ghp::main "${source_path}"
