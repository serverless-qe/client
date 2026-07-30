#!/usr/bin/env bash

# Copyright 2019 The OpenShift Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Synchs the ${REPO_BRANCH} branch to main and then triggers CI
# Usage: update-to-head.sh

set -e
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
REPO_OWNER_NAME="openshift-knative"
REPO_BRANCH=release-next
REPO_BRANCH_CI="${REPO_BRANCH}-ci"

# Check if there's an upstream release we need to mirror downstream
openshift/release/mirror-upstream-branches.sh

# Custom files
custom_files=$(cat <<EOT | tr '\n' ' '
openshift
OWNERS_ALIASES
OWNERS
Makefile
package_cliartifacts.sh
EOT
)

# Reset ${REPO_BRANCH} to upstream/main.
git fetch upstream main
git checkout upstream/main -B ${REPO_BRANCH}

# Remove GH Action hooks from upstream
rm -rf .github/workflows
git commit -sm ":fire: remove unneeded workflows" .github/

# Update openshift's main and take all needed files from there.
git fetch openshift main
git checkout openshift/main $custom_files
git add openshift OWNERS_ALIASES OWNERS Makefile
git commit -m ":open_file_folder: Update openshift specific files."

# Apply patches .
git apply openshift/patches/*
git commit -am ":fire: Apply carried patches."

git push -f openshift ${REPO_BRANCH}

# Trigger CI
git checkout ${REPO_BRANCH} -B ${REPO_BRANCH_CI}
message=":robot: Triggering CI on branch '${REPO_BRANCH}' after synching to upstream/main"
date > ci
git add ci
git commit -m "${message}"
git push -f openshift ${REPO_BRANCH_CI}

if hash hub 2>/dev/null; then
   # Test if there is already a sync PR in 
   COUNT=$(hub api -H "Accept: application/vnd.github.v3+json" repos/${REPO_OWNER_NAME}/${REPO_NAME}/pulls --flat \
    | grep -c "${message}") || true
   if [ "$COUNT" = "0" ]; then
      hub pull-request -m "${message}" -l "kind/sync-fork-to-upstream,approved,lgtm" -b ${REPO_OWNER_NAME}/${REPO_NAME}:${REPO_BRANCH} -h ${REPO_OWNER_NAME}/${REPO_NAME}:${REPO_BRANCH_CI}
   fi
else
   echo "hub (https://github.com/github/hub) is not installed, so you'll need to create a PR manually."
fi
