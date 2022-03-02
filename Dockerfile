FROM ghcr.io/stefanprodan/kube-tools:v1.7.1

#RUN apk add --update --no-cache curl yq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
