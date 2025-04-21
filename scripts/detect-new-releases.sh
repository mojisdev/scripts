#!/bin/bash

bail() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    printf '::error::%s\n' "$*"
  else
    printf >&2 'error: %s\n' "$*"
  fi
  exit 1
}
warn() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    printf '::warning::%s\n' "$*"
  else
    printf >&2 'warning: %s\n' "$*"
  fi
}
info() {
  printf >&2 'info: %s\n' "$*"
}

# function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install jq to run this script."
        exit 1
    fi
}

# check for jq
check_jq

# fetch the supported versions
if ! SUPPORTED_VERSIONS=$(curl -s "http://localhost:8787/api/v1/versions/supported"); then
    bail "failed to fetch supported versions"
fi

# fetch all versions
if ! ALL_VERSIONS=$(curl -s "http://localhost:8787/api/v1/versions?draft=true"); then
    bail "failed to fetch all versions"
fi

# extract emoji versions from all_versions
EMOJI_VERSIONS=$(echo "${ALL_VERSIONS}" | jq -r '.[].emoji_version')

# initialize flag to track if all versions are supported
ALL_SUPPORTED=true

# check each emoji version against supported versions
while IFS= read -r version; do
    # shellcheck disable=SC2250
    if ! echo "${SUPPORTED_VERSIONS}" | jq -e "contains([\"$version\"])" > /dev/null; then
        # shellcheck disable=SC2250
        echo "Missing support for emoji version: $version"
        ALL_SUPPORTED=false
    fi
done <<< "${EMOJI_VERSIONS}"

# if all versions are supported, exit early
if [[ "${ALL_SUPPORTED}" = true ]]; then
    info "🎉 all versions is currently supported"
    exit 0
fi

warn "❗️ not all versions are supported, please check the output above"
