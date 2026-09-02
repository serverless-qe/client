# DO NOT EDIT! Generated Dockerfile for test/test_images/helloworld.
ARG GO_BUILDER=registry.ci.openshift.org/openshift/release:rhel-9-release-golang-1.26-openshift-4.22
ARG GO_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal

FROM $GO_BUILDER as builder

WORKDIR /workspace
COPY . .

ENV CGO_ENABLED=1
ENV GOEXPERIMENT=strictfipsruntime

RUN go build -tags strictfipsruntime -o /usr/bin/main ./test/test_images/helloworld

FROM $GO_RUNTIME

ARG VERSION=knative-v1.17

COPY --from=builder /usr/bin/main /ko-app/helloworld
COPY LICENSE /licenses/

USER 65532

LABEL \
      com.redhat.component="openshift-serverless-1-client-test-test-images-helloworld-rhel9-container" \
      name="openshift-serverless-1/client-test-test-images-helloworld-rhel9" \
      version=$VERSION \
      summary="Red Hat OpenShift Serverless 1 Client Test Test Images Helloworld" \
      maintainer="serverless-support@redhat.com" \
      description="Red Hat OpenShift Serverless 1 Client Test Test Images Helloworld" \
      io.k8s.display-name="Red Hat OpenShift Serverless 1 Client Test Test Images Helloworld" \
      io.k8s.description="Red Hat OpenShift Serverless Client Test Test Images Helloworld" \
      io.openshift.tags="test-test-images-helloworld" \
      vendor="Red Hat, Inc." \
      release=$VERSION \
      cpe="cpe:/a:redhat:openshift_serverless:1.37::el9"

ENTRYPOINT ["/ko-app/helloworld"]
