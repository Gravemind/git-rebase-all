#!/bin/bash

set -euo pipefail

here="$(cd "$(dirname "$0")"; pwd)"
cd "$here"

pattern="${1:-}"

export TESTDIR="$here/tmp"
rm -rf "$TESTDIR"
mkdir -p "$TESTDIR"

tests=()
for t in ./tests/test_*.sh
do
  if [[ -n "$pattern" && "$t" != *"$pattern"* ]]
  then
    echo "Skipping test $t: does not match pattern ($pattern)"
    continue
  fi
  tests+=($t)
done

echo "Tests list: ${tests[*]}"

for t in "${tests[@]}"
do
  echo "Testing: $t"
  ret=0
  bash $t || ret=$?
  if [[ "$ret" -ne 0 ]]
  then
    echo -e "\n\nTest failed:\n - $t: FAILED\n\n"
    exit 1
  fi
done

echo -e "\n\nAll tests OK:"
printf " - %s: OK\n" "${tests[@]}"
echo -e "\n"
