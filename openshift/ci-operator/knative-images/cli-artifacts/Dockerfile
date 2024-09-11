# This is not generated Dockerfile, yet!
ARG GO_BUILDER=registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.22-openshift-4.17
ARG GO_RUNTIME=registry.access.redhat.com/ubi8/ubi-minimal

FROM $GO_BUILDER as builder

WORKDIR /go/src/github.com/knative/client
COPY . .

ENV CGO_ENABLED=1
ENV GOEXPERIMENT=strictfipsruntime
# Pass to cross compile target
ENV GOFLAGS="-tags=strictfipsruntime"

RUN make build-cross &&  \
    bash package_cliartifacts.sh

ARG VERSION=knative-v1.15
FROM $GO_RUNTIME

RUN mkdir -p /usr/share/kn/{linux_amd64,linux_arm64,linux_ppc64le,linux_s390x,macos_amd64,macos_arm64,windows}

COPY --from=builder /go/src/github.com/knative/client/kn-linux-amd64.tar.gz /usr/share/kn/linux_amd64/
COPY --from=builder /go/src/github.com/knative/client/kn-linux-arm64.tar.gz /usr/share/kn/linux_arm64/
COPY --from=builder /go/src/github.com/knative/client/kn-linux-ppc64le.tar.gz /usr/share/kn/linux_ppc64le/
COPY --from=builder /go/src/github.com/knative/client/kn-linux-s390x.tar.gz /usr/share/kn/linux_s390x/
COPY --from=builder /go/src/github.com/knative/client/kn-macos-amd64.tar.gz /usr/share/kn/macos_amd64/
COPY --from=builder /go/src/github.com/knative/client/kn-macos-arm64.tar.gz /usr/share/kn/macos_arm64/
COPY --from=builder /go/src/github.com/knative/client/kn-windows-amd64.zip  /usr/share/kn/windows/
COPY --from=builder /go/src/github.com/knative/client/LICENSE  /usr/share/kn/LICENSE

USER 65532

LABEL \
      com.redhat.component="openshift-serverless-1-kn-cli-artifacts-rhel8-container" \
      name="openshift-serverless-1/kn-cli-artifacts-rhel8" \
      version=$VERSION \
      summary="Red Hat OpenShift Serverless 1 kn CLI artifacts" \
      maintainer="serverless-support@redhat.com" \
      description="Red Hat OpenShift Serverless 1 kn CLI artifacts" \
      io.k8s.display-name="Red Hat OpenShift Serverless 1 kn CLI artifacts"

