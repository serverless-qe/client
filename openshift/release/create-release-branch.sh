#!/bin/bash

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

# Usage: create-release-branch.sh v0.4.1 release-0.4

release=$1
target=$2

ROOT_DIR=$(dirname "$0")/../..
source "$ROOT_DIR/openshift/release/common.sh"

# Custom files
custom_files=$(cat <<EOT | tr '\n' ' '
.github/workflows
openshift
OWNERS
Makefile
package_cliartifacts.sh
EOT
)

# Fetch the latest tags and checkout a new branch from the wanted tag.
git fetch upstream --tags
git checkout -b "$target" "$release"

# Remove GH Action hooks from upstream
rm -rf .github/workflows
git commit -sm ":fire: remove unneeded workflows" .github/

# Remove unneeded files from upstream
git rm -f --ignore-unmatch OWNERS_ALIASES
git commit -sm ":fire: remove unneeded files" OWNERS_ALIASES

# Update openshift's main and take all needed files from there.
tag=${target/release-/}
git fetch openshift main
git checkout openshift/main $custom_files
yq write --inplace openshift/project.yaml project.tag "knative-$tag"
make generate-release
git add .
git commit -m "Add openshift specific files."

# Apply patches .
PATCH_DIR="openshift/patches"
# Use release-specific patch dir if exists
if [ -d "openshift/patches-${release}" ]; then
    PATCH_DIR="openshift/patches-${release}"
fi
git apply $PATCH_DIR/*
git commit -am ":fire: Apply carried patches."

