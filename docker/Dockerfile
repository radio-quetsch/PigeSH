FROM golang:alpine AS supercronic_builder

RUN go install  github.com/aptible/supercronic@latest

FROM alpine:3.20

WORKDIR /app

COPY --from=supercronic_builder /go/bin/supercronic /usr/local/bin/supercronic

COPY ./pige.sh .

COPY ./docker/start.sh /usr/local/bin/start.sh
COPY ./docker/crontab . 

RUN apk add --update \
        ffmpeg \ 
        tzdata \
        bash && \
    chmod a+x \
        /app/pige.sh \
        /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]