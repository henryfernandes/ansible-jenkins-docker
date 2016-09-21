# Start from a Debian image with the latest version of Go installed
# and a workspace (GOPATH) configured at /go.
FROM golang

ADD deploy/helloapp /go/bin/helloapp

ENTRYPOINT ["/go/bin/helloapp"]
