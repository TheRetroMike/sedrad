# -- multistage docker build: stage #1: build stage
FROM golang:1.19-alpine AS build

RUN mkdir -p /go/src/github.com/theretromike/sedrad

WORKDIR /go/src/github.com/theretromike/sedrad

RUN apk add --no-cache curl git openssh binutils gcc musl-dev

COPY go.mod .
COPY go.sum .


# Cache sedrad dependencies
RUN go mod download

COPY . .

RUN go build $FLAGS -o sedrad .

# --- multistage docker build: stage #2: runtime image
FROM alpine
WORKDIR /app

#RUN apk add --no-cache ca-certificates tini

COPY --from=build /go/src/github.com/theretromike/sedrad/sedrad /usr/bin/sedrad
#COPY --from=build /go/src/github.com/theretromike/sedrad/infrastructure/config/sample-sedrad.conf /app/

#USER nobody
#ENTRYPOINT [ "/sbin/tini", "--" ]
#COPY --from=build /bugna/bin/* /usr/bin/

ENTRYPOINT [ "/usr/bin/sedrad" ]
