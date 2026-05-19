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

function install_sobranch_hack_tool() {
  go install github.com/openshift-knative/hack/cmd/sobranch@latest
  return $?
}

repo_root_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..

install_generate_hack_tool || exit 1
install_sobranch_hack_tool || exit 1

# --app-file-fmt is used to mimic ko build, it's assumed in --cmd flag tests
"$(go env GOPATH)"/bin/generate \
  --root-dir "${repo_root_dir}" \
  --generators dockerfile \
  --excludes ".*k8s\\.io.*" \
  --excludes ".*knative.dev/pkg/codegen.*" \
  --excludes ".*knative.dev/hack/cmd/script.*" \
  --app-file-fmt "/ko-app/%s" \
  --generate-rpms-lock-file \
  --dockerfile-image-builder-fmt "registry.ci.openshift.org/openshift/release:rhel-9-release-golang-1.25-openshift-4.21"

echo "Get Release version and according SO version"
release=$(yq r openshift/project.yaml project.tag)
release=${release/knative-/}
so_branch=$("$(go env GOPATH)"/bin/sobranch --upstream-version="${release}")
so_release=${so_branch/release-/}

echo "Release: $release"
echo "ServerlessOperator Version: $so_release"

# TODO: update to according SO version (we can't do it initially, because the image does not exist at the beginning)
FUNC_UTIL=$(skopeo inspect -n --format '{{.Digest}}' docker://quay.io/redhat-user-workloads/ocp-serverless-tenant/serverless-operator-138/kn-plugin-func-func-util:latest --override-os linux --override-arch amd64)
EVENT_SENDER=$(skopeo inspect -n --format '{{.Digest}}' docker://quay.io/redhat-user-workloads/ocp-serverless-tenant/serverless-operator-138/kn-plugin-event-sender:latest --override-os linux --override-arch amd64)

echo "func-util sha: ${FUNC_UTIL}"
echo "event-sender sha: ${EVENT_SENDER}"

echo "Update kn image refs"
sed -i "/RUN go build.*/ i \
ENV KN_PLUGIN_FUNC_UTIL_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-func-func-util-rhel9@${FUNC_UTIL}\n\
ENV KN_PLUGIN_EVENT_SENDER_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-event-sender-rhel9@${EVENT_SENDER}" openshift/ci-operator/knative-images/kn/Dockerfile

echo "Update cli-artifacts image refs"
sed -i "s|ENV KN_PLUGIN_FUNC_UTIL_IMAGE.*|ENV KN_PLUGIN_FUNC_UTIL_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-func-func-util-rhel9@${FUNC_UTIL}|g" openshift/ci-operator/knative-images/cli-artifacts/Dockerfile
sed -i "s|ENV KN_PLUGIN_EVENT_SENDER_IMAGE.*|ENV KN_PLUGIN_EVENT_SENDER_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-event-sender-rhel9@${EVENT_SENDER}|g" openshift/ci-operator/knative-images/cli-artifacts/Dockerfile

echo "Update Tag"
sed -i "s|ENV TAG=.*|ENV TAG="${release}".0|g" openshift/ci-operator/knative-images/cli-artifacts/Dockerfile

echo "Update Version arg"
grep -rlZ "ARG VERSION=knative-v" openshift/ci-operator/ | xargs -0 sed -i "s|ARG VERSION=knative-v.*|ARG VERSION=knative-${release}|g"

echo "Update cpe label"
grep -rlZ "cpe:/a:redhat:openshift_serverless:" openshift/ci-operator/ | xargs -0 sed -i "s|cpe=\"cpe:/a:redhat:openshift_serverless:.*\"|cpe=\"cpe:/a:redhat:openshift_serverless:${so_release}::el9\"|g"
