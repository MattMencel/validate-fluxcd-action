FROM ghcr.io/stefanprodan/kube-tools:v1.7.1

RUN curl -sL https://github.com/rikatz/kubepug/releases/download/v1.3.2/kubepug_linux_amd64.tar.gz | tar zxf - -C /bin

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
