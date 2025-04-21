#!/usr/bin/env bash

set -CeEuo pipefail
IFS=$'\n\t'

INPUT_SCRIPT="$1"

# list of allowed script names
ALLOWED_SCRIPTS=(
  "detect-new-releases"
)

# check if script name is in list, and bail
SCRIPT_FOUND=0
for script in "${ALLOWED_SCRIPTS[@]}"; do
  if [[ "${INPUT_SCRIPT}" = "${script}" ]]; then
    SCRIPT_FOUND=1
    break
  fi
done

if [[ "${SCRIPT_FOUND}" -eq 0 ]]; then
  echo "error: invalid script name '${INPUT_SCRIPT}'"
  echo "allowed scripts: ${ALLOWED_SCRIPTS[*]}"
  exit 1
fi

# execute the script
SCRIPT_PATH="$(dirname "$0")/scripts/${INPUT_SCRIPT}.sh"
if [[ ! -f "${SCRIPT_PATH}" ]]; then
  echo "error: script file not found at ${SCRIPT_PATH}"
  exit 1
fi

# run the script
bash "${SCRIPT_PATH}"
