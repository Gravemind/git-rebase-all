#!/bin/bash

set -euo pipefail

dir="$TESTDIR/octomerge_conflict"
git init "$dir"
cd "$dir"

git commit -m 'first commit' --allow-empty

echo file > file
git add file
git commit -m "master"

git checkout -b brancha master
echo afile > afile
git add afile
git commit -m "brancha"

git checkout -b branchb master
echo bfile > afile
git add afile
git commit -m "branchb"

git checkout -b newmaster master
echo newfile > newfile
git add newfile
git commit -m 'newmaster newfile'

oldmaster="$(git rev-parse master)"
oldnewmaster="$(git rev-parse newmaster)"
olda="$(git rev-parse brancha)"
oldb="$(git rev-parse branchb)"

git --no-pager log --graph --all --oneline --decorate --author-date-order

#
git rebase-all newmaster master
#

git --no-pager log --graph --all --oneline --decorate --author-date-order

# Check masters did not changed
test "$(git rev-parse master)" = "$oldmaster"
test "$(git rev-parse newmaster)" = "$oldnewmaster"

# Check new branches actually changed
test "$(git rev-parse brancha)" != "$olda"
test "$(git rev-parse branchb)" != "$oldb"

# Check new branches contains new upstream
git branch --contains newmaster | grep -q brancha
git branch --contains newmaster | grep -q branchb

echo OK
