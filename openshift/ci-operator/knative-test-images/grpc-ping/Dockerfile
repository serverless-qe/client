# DO NOT EDIT! Generated Dockerfile for vendor/knative.dev/serving/test/test_images/grpc-ping.
ARG GO_BUILDER=registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.22-openshift-4.17
ARG GO_RUNTIME=registry.access.redhat.com/ubi8/ubi-minimal

FROM $GO_BUILDER as builder

COPY . .

ENV CGO_ENABLED=1
ENV GOEXPERIMENT=strictfipsruntime

RUN go build -tags strictfipsruntime -o /usr/bin/main ./vendor/knative.dev/serving/test/test_images/grpc-ping

FROM $GO_RUNTIME

ARG VERSION=knative-v1.15

COPY --from=builder /usr/bin/main /ko-app/grpc-ping

USER 65532

LABEL \
      com.redhat.component="openshift-serverless-1-eventing-vendor-knative.dev-serving-test-test-images-grpc-ping-rhel8-container" \
      name="openshift-serverless-1/eventing-vendor-knative.dev-serving-test-test-images-grpc-ping-rhel8" \
      version=$VERSION \
      summary="Red Hat OpenShift Serverless 1 Eventing Vendor Knative.Dev Serving Test Test Images Grpc Ping" \
      maintainer="serverless-support@redhat.com" \
      description="Red Hat OpenShift Serverless 1 Eventing Vendor Knative.Dev Serving Test Test Images Grpc Ping" \
      io.k8s.display-name="Red Hat OpenShift Serverless 1 Eventing Vendor Knative.Dev Serving Test Test Images Grpc Ping" \
      io.k8s.description="Red Hat OpenShift Serverless Eventing Vendor Knative.Dev Serving Test Test Images Grpc Ping" \
      io.openshift.tags="vendor-knative.dev-serving-test-test-images-grpc-ping"

ENTRYPOINT ["/ko-app/grpc-ping"]
