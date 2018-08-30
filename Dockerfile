# Build Kubernetes TF provider fork
FROM golang:1.10 as builder
RUN go get github.com/sl1pm4t/terraform-provider-kubernetes &&\
    cd /go/src/github.com/sl1pm4t/terraform-provider-kubernetes &&\
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

# Build image with Kubernetes provider
FROM alpine:latest

ENV TERRAFORM_VERSION=0.10.0
ENV TERRAFORM_SHA256SUM=f991039e3822f10d6e05eabf77c9f31f3831149b52ed030775b6ec5195380999

RUN apk add --update git curl openssh bash && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY --from=builder /go/src/github.com/sl1pm4t/terraform-provider-kubernetes/terraform-provider-kubernetes /root/.terraform.d/plugins/

ENTRYPOINT ["/bin/terraform"]
