#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"

# check for jq
check_jq

BASE_URL="${INPUT_MOJIS_API_BASE_URL:-"https://api.mojis.dev"}"

info "🔍 checking for new releases"
info "🔗 base url: ${BASE_URL}"

# fetch the supported versions
if ! SUPPORTED_VERSIONS=$(curl -s "${BASE_URL}/api/v1/versions/supported"); then
    bail "failed to fetch supported versions"
fi

# fetch all versions
if ! ALL_VERSIONS=$(curl -s "${BASE_URL}/api/v1/versions?draft=true"); then
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
