# Build Kubernetes TF provider fork
FROM golang:1.10 as builder
RUN go get github.com/sl1pm4t/terraform-provider-kubernetes &&\
    cd /go/src/github.com/sl1pm4t/terraform-provider-kubernetes &&\
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

# Build image with Kubernetes provider
FROM terraform:light
RUN apk add --no-cache bash
COPY --from=builder /go/src/github.com/sl1pm4t/terraform-provider-kubernetes/terraform-provider-kubernetes /root/.terraform.d/plugins/
ENTRYPOINT ["/bin/terraform"]
