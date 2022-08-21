#!/bin/bash

# Check if script being sourced
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
(return 0 2>/dev/null) && sourced=1

version() {
    local component_dir=${1-.}
    cd ${component_dir} && echo ${PREFIX:+"${PREFIX}-"}$(cat VERSION | tr -d '[:space:]')
}

revision() {
    local component_dir=${1-.}
    cd ${component_dir} && {
        [ -n "$GITHUB_SHA" ] && echo "${GITHUB_SHA::7}" || echo "$(git rev-parse --short HEAD)"
    }
}

dirty() {
    local component_dir=${1-.}
    cd ${component_dir} && [ -z "$GITHUB_SHA" ] && ! git diff --quiet origin/main..HEAD && echo '-dirty'
}

fullversion() {
    local component_dir=${1-.}
    cd ${component_dir} && echo "$(version)_rev-$(revision)$(dirty)"
}

# Check if script is being sourced
(return 0 2>/dev/null) && return 0

case "${1-short}" in
    short) version $2 ;;
    long | full) fullversion $2 ;;
    * ) echo "invalid type"; exit 1 ;;
esac
