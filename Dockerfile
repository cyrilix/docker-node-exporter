FROM --platform=$BUILDPLATFORM golang:1.14-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG version="v0.16.0"


WORKDIR /opt

RUN apk add -U git
RUN git clone https://github.com/prometheus/node_exporter.git
WORKDIR /opt/node_exporter
RUN git checkout ${version}

RUN GOOS=$(echo $TARGETPLATFORM | cut -f1 -d/) && \
    GOARCH=$(echo $TARGETPLATFORM | cut -f2 -d/) && \
    GOARM=$(echo $TARGETPLATFORM | cut -f3 -d/ | sed "s/v//" ) && \
    GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go mod init && \
    GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go mod vendor && \
    CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} GOARM=${GOARM} go build ./



FROM gcr.io/distroless/static

COPY --from=builder /opt/node_exporter/node_exporter /bin/node_exporter

EXPOSE      9100
USER        1234
ENTRYPOINT  [ "/bin/node_exporter" ]


