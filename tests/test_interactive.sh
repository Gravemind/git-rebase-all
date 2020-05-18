#!/bin/bash

set -euo pipefail

dir="$TESTDIR/interactive"
git init "$dir"
cd "$dir"

git commit -m 'first commit' --allow-empty

git checkout -b brancha master
git commit -m "brancha" --allow-empty

git checkout -b branchb master
git commit -m "branchb" --allow-empty

git checkout -b newmaster master
git commit -m 'newmaster' --allow-empty

export _EDIT_FILE=$(pwd)/interactive_works
rm -f "$_EDIT_FILE"
EDITOR="bash -c 'echo itworks > $_EDIT_FILE'"

#
git rebase-all --interactive newmaster master
#

test "$(cat "$_EDIT_FILE")" = itworks
