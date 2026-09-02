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
  --excludes ".*k8s\\.io.*" \
  --excludes ".*knative.dev/pkg/codegen.*" \
  --excludes ".*knative.dev/hack/cmd/script.*" \
  --app-file-fmt "/ko-app/%s" \
  --generate-rpms-lock-file


#git apply $repo_root_dir/openshift/dockerfile.patch
FUNC_UTIL=$(skopeo inspect -n --format '{{.Digest}}' docker://quay.io/redhat-user-workloads/ocp-serverless-tenant/serverless-operator-137/kn-plugin-func-func-util:1.37.1 --override-os linux --override-arch amd64)
EVENT_SENDER=$(skopeo inspect -n --format '{{.Digest}}' docker://quay.io/redhat-user-workloads/ocp-serverless-tenant/serverless-operator-137/kn-plugin-event-sender:1.37.1 --override-os linux --override-arch amd64)

echo "func-util sha: ${FUNC_UTIL}"
echo "event-sender sha: ${EVENT_SENDER}"

echo "Update kn image refs"
sed -i "/RUN go build.*/ i \
ENV KN_PLUGIN_FUNC_UTIL_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-func-func-util-rhel9@${FUNC_UTIL}\n\
ENV KN_PLUGIN_EVENT_SENDER_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-event-sender-rhel9@${EVENT_SENDER}" openshift/ci-operator/knative-images/kn/Dockerfile

echo "Update cli-artifacts image refs"
sed -i "s|ENV KN_PLUGIN_FUNC_UTIL_IMAGE.*|ENV KN_PLUGIN_FUNC_UTIL_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-func-func-util-rhel9@${FUNC_UTIL}|g" openshift/ci-operator/knative-images/cli-artifacts/Dockerfile
sed -i "s|ENV KN_PLUGIN_EVENT_SENDER_IMAGE.*|ENV KN_PLUGIN_EVENT_SENDER_IMAGE=registry.redhat.io/openshift-serverless-1/kn-plugin-event-sender-rhel9@${EVENT_SENDER}|g" openshift/ci-operator/knative-images/cli-artifacts/Dockerfile

