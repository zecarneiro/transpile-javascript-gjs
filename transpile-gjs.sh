#!/bin/bash
# Author: José M. C. Noronha
ME_VAR=""
JS_SOURCES_DIR=""

function validateMeVariablePositions() {
  local file="$1"
  local firstImportLine=$(cat "$file" | grep -n -E "import (.*) from ([\'|\"].*[\'|\"])" | cut -d : -f 1 | head -1)
  local firstMeVarLine=$(cat "$file" | grep -n "imports.misc.extensionUtils.getCurrentExtension()" | cut -d : -f 1 | head -1)
  if [[ -n "$firstImportLine" ]]; then
    if [[ -z "$firstMeVarLine" ]] || [[ $firstMeVarLine -ge $firstImportLine ]]; then
      echo "ERROR: On the file \"$file\""
      echo "ERROR: \"imports.misc.extensionUtils.getCurrentExtension()\", must be on the top of the file or before all imports"
      exit 1
    fi
  fi
}

function processImports() {
  local file="$1"
  sed -i -E "s/import \* as (\w+) from '(.*)'/const \1 = ${ME_VAR}.imports.\2/g" "${file}"
  sed -i -E "s/import \* as (\w+) from \"(.*)\"/const \1 = ${ME_VAR}.imports.\2/g" "${file}"
  sed -i -E "s/import \{(.*)\} from '(.*)'/const \{\1\} = ${ME_VAR}.imports.\2/g" "${file}"
  sed -i -E "s/import \{(.*)\} from \"(.*)\"/const \{\1\} = ${ME_VAR}.imports.\2/g" "${file}"
  while IFS= read -r line; do
    if [[ -n "${line}" ]]; then
      for src in $(find "$JS_SOURCES_DIR" -name '*.js'); do
        baseFileName=$(basename "${src}" .js)
        if [[ $(echo "$line" | grep -c "${baseFileName}") -gt 0 ]]; then
          local newWithoutSrc=${src/$JS_SOURCES_DIR/}
          newWithoutSrc=${newWithoutSrc/.js/}
          newWithoutSrc=$(echo "${newWithoutSrc}" | sed -r "s#/#.#g")
          beforEqual=$(echo "${line}" | cut -d'=' -f 1)
          sed -i "s#${line}#${beforEqual} = ${ME_VAR}.imports${newWithoutSrc};#g" "$file"
        fi
      done
    fi
  done <<<$(cat "$file" | grep -E "$ME_VAR.imports.*.\/")
}

function transpile() {
  local file="$1"
  sed -i 's#export function#function#g' "$file"
  sed -i 's#export var#var#g' "$file"
  sed -i 's#export const#var#g' "$file"
  sed -i 's#Object.defineProperty(exports, "__esModule", { value: true });#var exports = {};#g' "$file"
  sed -i -E 's/export class (\w+)/var \1 = class \1/g' "$file"
  processImports "$file"
}

function main() {
  ME_VAR="$1"
  JS_SOURCES_DIR="$2"
  if [[ -z "${ME_VAR}" ]]; then
    echo "ERROR: Invalid ME variable"
    exit 1
  fi
  if [[ -z "${JS_SOURCES_DIR}" ]]; then
    JS_SOURCES_DIR=$(cat "tsconfig.json" | grep "outDir" | cut -d ":" -f 2- | tr -d ',' | tr -d '"' | tr -d ' ')
    if [[ -z "${JS_SOURCES_DIR}" ]]; then
      echo "ERROR: Invalid JavaScript sources directory"
      exit 1
    fi
  fi
  echo "Transpile to standard JS. Out comes GJS-compatible JS"
  for src in $(find "$JS_SOURCES_DIR" -name '*.js'); do
    validateMeVariablePositions "$src"
    transpile "$src"
  done
  echo "Transpile to standard JS. Out comes GJS-compatible JS - Done!"
}
main "$@"
