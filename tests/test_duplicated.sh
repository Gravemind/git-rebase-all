#!/bin/bash

set -euo pipefail

dir="$TESTDIR/duplicated"
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
echo bfile > bfile
git add bfile
git commit -m "branchb"

git checkout -b newmaster master
echo newfile > newfile
git add newfile
git commit -m 'newmaster newfile'

git branch branchb_dup branchb

oldmaster="$(git rev-parse master)"
oldnewmaster="$(git rev-parse newmaster)"
olda="$(git rev-parse brancha)"
oldb="$(git rev-parse branchb)"
oldbd="$(git rev-parse branchb_dup)"

git --no-pager log --graph --all --oneline --decorate --author-date-order

#
git rebase-all newmaster master
#

git --no-pager log --graph --all --oneline --decorate --author-date-order

# Test Sanity check
test "$(git rev-parse branchb)" != "$oldb"

# Check branchb and branchb_dup a still the same commit
test "$(git rev-parse branchb)" == "$(git rev-parse branchb_dup)"

# Check new branches contains new upstream
git branch --contains newmaster | grep -q brancha
git branch --contains newmaster | grep -q branchb
git branch --contains newmaster | grep -q branchb_dup


echo OK
