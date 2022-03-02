FROM alpine:3.15

RUN apk add --update --no-cache curl yq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
