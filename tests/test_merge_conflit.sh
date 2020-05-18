#!/bin/bash

set -euo pipefail

dir="$TESTDIR/merge_conflict"
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

git checkout -b branchc master
echo cfile > afile
git add afile
git commit -m "branchc"
git merge --no-edit --no-commit branchb || true
# There is the conflict
test -n "$(git ls-files -u afile)"
echo 'resolve' > afile
git add afile
git commit --no-edit
old_branchc_afile="$(cat afile)"

git checkout -b newmaster master
echo newfile > newfile
git add newfile
git commit -m 'newmaster newfile'

oldmaster="$(git rev-parse master)"
oldnewmaster="$(git rev-parse newmaster)"
olda="$(git rev-parse brancha)"
oldb="$(git rev-parse branchb)"

echo "Before rebase:"
git --no-pager log --graph --all --oneline --decorate --author-date-order

#
git rebase-all newmaster master || true
echo "During rebase merge conflict resolution:"
git --no-pager log --graph --all --oneline --decorate --author-date-order
test -n "$(git ls-files -u afile)"
echo 'resolve' > afile
git add afile
git commit --no-edit
git rebase-all --continue
#

echo "After rebase:"
git --no-pager log --graph --all --oneline --decorate --author-date-order

test "$(git show branchc:afile)" = "$old_branchc_afile"

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
