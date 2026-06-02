# DO NOT EDIT! Generated Dockerfile for vendor/knative.dev/serving/test/test_images/multicontainer/servingcontainer.
ARG GO_BUILDER=registry.ci.openshift.org/openshift/release:rhel-8-release-golang-1.25-openshift-4.21
ARG GO_RUNTIME=registry.access.redhat.com/ubi8/ubi-minimal

FROM $GO_BUILDER as builder

WORKDIR /workspace
COPY . .

ENV CGO_ENABLED=1
ENV GOEXPERIMENT=strictfipsruntime

RUN go build -tags strictfipsruntime -o /usr/bin/main ./vendor/knative.dev/serving/test/test_images/multicontainer/servingcontainer

FROM $GO_RUNTIME

ARG VERSION=knative-v1.15

COPY --from=builder /usr/bin/main /ko-app/servingcontainer
COPY LICENSE /licenses/

USER 65532

LABEL \
      com.redhat.component="openshift-serverless-1-client-vendor-knative.dev-serving-test-test-images-multicontainer-servingcontainer-rhel8-container" \
      name="openshift-serverless-1/client-vendor-knative.dev-serving-test-test-images-multicontainer-servingcontainer-rhel8" \
      version=$VERSION \
      summary="Red Hat OpenShift Serverless 1 Client Vendor Knative.Dev Serving Test Test Images Multicontainer Servingcontainer" \
      maintainer="serverless-support@redhat.com" \
      description="Red Hat OpenShift Serverless 1 Client Vendor Knative.Dev Serving Test Test Images Multicontainer Servingcontainer" \
      io.k8s.display-name="Red Hat OpenShift Serverless 1 Client Vendor Knative.Dev Serving Test Test Images Multicontainer Servingcontainer" \
      io.k8s.description="Red Hat OpenShift Serverless Client Vendor Knative.Dev Serving Test Test Images Multicontainer Servingcontainer" \
      io.openshift.tags="vendor-knative.dev-serving-test-test-images-multicontainer-servingcontainer" \
      vendor="Red Hat, Inc." \
      release=$VERSION \
      cpe="cpe:/a:redhat:openshift_serverless:1.35::el8"
      
ENTRYPOINT ["/ko-app/servingcontainer"]
