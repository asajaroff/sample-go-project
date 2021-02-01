FROM golang:1.15-buster as builder

RUN apt install -y git

WORKDIR /tmp/build

COPY . .

RUN go mod download

RUN go build -o ./out/sample-go-project ./src/server.go

FROM debian:buster-slim as runtime

ARG BUILD_DATE
ARG BUILD_VCS_REF
ARG BUILD_VERSION

COPY --from=builder /tmp/build/out/sample-go-project /app/sample-go-project

EXPOSE 8080

CMD ["/app/micrologger"]