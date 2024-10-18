# DO NOT EDIT! Generated Dockerfile for test/test_images/helloworld.
ARG GO_BUILDER=registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.22-openshift-4.17
ARG GO_RUNTIME=registry.access.redhat.com/ubi8/ubi-minimal

FROM $GO_BUILDER as builder

COPY . .

ENV CGO_ENABLED=1
ENV GOEXPERIMENT=strictfipsruntime

RUN go build -tags strictfipsruntime -o /usr/bin/main ./test/test_images/helloworld

FROM $GO_RUNTIME

ARG VERSION=knative-v1.15

COPY --from=builder /usr/bin/main /ko-app/helloworld

USER 65532

LABEL \
      com.redhat.component="openshift-serverless-1-eventing-test-test-images-helloworld-rhel8-container" \
      name="openshift-serverless-1/eventing-test-test-images-helloworld-rhel8" \
      version=$VERSION \
      summary="Red Hat OpenShift Serverless 1 Eventing Test Test Images Helloworld" \
      maintainer="serverless-support@redhat.com" \
      description="Red Hat OpenShift Serverless 1 Eventing Test Test Images Helloworld" \
      io.k8s.display-name="Red Hat OpenShift Serverless 1 Eventing Test Test Images Helloworld" \
      io.k8s.description="Red Hat OpenShift Serverless Eventing Test Test Images Helloworld" \
      io.openshift.tags="test-test-images-helloworld"

ENTRYPOINT ["/ko-app/helloworld"]
