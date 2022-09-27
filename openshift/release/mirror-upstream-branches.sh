#!/usr/bin/env bash

# Usage: openshift/release/mirror-upstream-branches.sh
# This should be run from the basedir of the repo with no arguments


set -ex
readonly TMPDIR=$(mktemp -d knativeClientBranchingCheckXXXX -p /tmp/)

git fetch upstream --tags
git fetch openshift --tags

# We need to seed this with a few releases that, otherwise, would make
# the processing regex less clear with more anomalies
cat >> "$TMPDIR"/midstream_branches <<EOF
0.2
0.3
EOF

git branch --list -a "upstream/release-1.*" | cut -f3 -d'/' | cut -f2 -d'-' > "$TMPDIR"/upstream_branches
git branch --list -a "openshift/release-v1.*" | cut -f3 -d'/' | cut -f2 -d'v' | cut -f1,2 -d'.' >> "$TMPDIR"/midstream_branches

sort -o "$TMPDIR"/midstream_branches "$TMPDIR"/midstream_branches
sort -o "$TMPDIR"/upstream_branches "$TMPDIR"/upstream_branches
comm -32 "$TMPDIR"/upstream_branches "$TMPDIR"/midstream_branches > "$TMPDIR"/new_branches

UPSTREAM_BRANCHES=$(cat "$TMPDIR"/new_branches | tr '\n' ' ')

if [ -z "$UPSTREAM_BRANCHES" ]; then
    echo "no new branch, exiting"
    exit 0
fi

for UPSTREAM_BRANCH in ${UPSTREAM_BRANCHES[@]}; do
  echo "found upstream branch: $UPSTREAM_BRANCH"
  UPSTREAM_TAG="knative-v$UPSTREAM_BRANCH.0"
  MIDSTREAM_BRANCH="release-v$UPSTREAM_BRANCH"
  $(dirname "${BASH_SOURCE[0]}")/create-release-branch.sh "$UPSTREAM_TAG" "$MIDSTREAM_BRANCH"
  # we would check the error code, but we 'set -e', so assume we're fine
  git push openshift "$MIDSTREAM_BRANCH"
done
