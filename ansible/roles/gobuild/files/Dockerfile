# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang

RUN mkdir -p /go/src/helloapp
RUN mkdir -p /tmp/deploy/

ADD buildgo.sh buildgo.sh
