# This simulator runs devp2p protocol tests.

# Build devp2p tool.
FROM golang:1-alpine as sila-builder
ARG GOPROXY
ENV GOPROXY=${GOPROXY}
RUN apk add --update git gcc musl-dev linux-headers
RUN git clone --depth 1 https://github.com/sila-chain/go-sila.git /go-sila
WORKDIR /go-sila
RUN go build -v ./cmd/devp2p

# Build the simulator executable.
FROM golang:1-alpine as sim-builder
ARG GOPROXY
ENV GOPROXY=${GOPROXY}
RUN apk add --update git gcc musl-dev linux-headers
WORKDIR /source
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -v -o devp2p-simulator

# Build the simulation run container.
FROM alpine:latest
ADD . /source
WORKDIR /source
COPY --from=sila-builder /go-sila/devp2p ./devp2p
COPY --from=sila-builder /go-sila/cmd/devp2p/internal/ethtest/testdata /testchain
COPY --from=sim-builder /source/devp2p-simulator .
ENTRYPOINT ["./devp2p-simulator"]
