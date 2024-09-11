#!/usr/bin/env bash
#
# This script generates the productized Dockerfiles
#

set -o errexit
set -o nounset
set -o pipefail

function install_generate_hack_tool() {
  go install github.com/openshift-knative/hack/cmd/generate@latest
  return $?
}

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

install_generate_hack_tool || exit 1

# --app-file-fmt is used to mimic ko build, it's assumed in --cmd flag tests
"$(go env GOPATH)"/bin/generate \
  --root-dir "${repo_root_dir}" \
  --generators dockerfile \
  --app-file-fmt "/ko-app/%s" \
  --dockerfile-image-builder-fmt "registry.ci.openshift.org/openshift/release:rhel-8-release-golang-%s-openshift-4.17"