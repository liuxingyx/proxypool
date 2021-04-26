FROM golang:alpine as builder

ENV GOPROXY https://goproxy.cn
ENV GO111MODULE on

RUN apk add --no-cache make git
WORKDIR /proxypool-src
COPY . /proxypool-src
RUN go mod download && \
    make docker && \
    mv ./bin/proxypool-docker /proxypool

FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata
WORKDIR /proxypool-src
COPY ./assets /proxypool-src/assets
COPY ./config/config.yaml /proxypool-src/config.yaml
COPY ./config/source.yaml /proxypool-src/source.yaml
COPY --from=builder /proxypool /proxypool-src/
#ENTRYPOINT ["/proxypool-src/proxypool"]
ENTRYPOINT ["/proxypool-src/proxypool","-c"]
CMD ["/proxypool-src/config.yaml"]