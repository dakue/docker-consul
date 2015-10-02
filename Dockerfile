FROM alpine:3.2

ENV CONSUL_VERSION=0.5.2 \
  CONSUL_HOME="/opt/consul" \
  GOSU_VERSION=1.4 \
  ENVPLATE_VERSION=0.0.8

RUN set -x && \ 
  apk --update add bash curl ca-certificates && \
  curl -sSL https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk -o /tmp/glibc-2.21-r2.apk && \
  apk add --allow-untrusted /tmp/glibc-2.21-r2.apk && \
  rm -rf /tmp/glibc-2.21-r2.apk /var/cache/apk/*

RUN set -x && \
  curl -sSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" -o /usr/local/bin/gosu && \
  chmod +x /usr/local/bin/gosu && \
  curl -ssL "https://github.com/kreuzwerker/envplate/releases/download/v${ENVPLATE_VERSION}/ep-linux" -o /usr/local/bin/ep && \
  chmod +x /usr/local/bin/ep && \
  ln -s /usr/local/bin/ep /usr/local/bin/envplate

RUN set -x && \
  curl -sSL "https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_linux_amd64.zip" -o /tmp/${CONSUL_VERSION}_linux_amd64.zip && \
  curl -sSL "https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_web_ui.zip" -o /tmp/${CONSUL_VERSION}_web_ui.zip && \
  curl -sSL "https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_SHA256SUMS?direct" -o /tmp/${CONSUL_VERSION}_SHA256SUMS && \
  grep 'linux_amd64.zip' /tmp/${CONSUL_VERSION}_SHA256SUMS | sed "s|${CONSUL_VERSION}|/tmp/${CONSUL_VERSION}|g" > /tmp/consul.sha256 && \
  sha256sum -c /tmp/consul.sha256 && \
  cd /usr/local/bin && \
  unzip /tmp/${CONSUL_VERSION}_linux_amd64.zip && \
  chmod +x /usr/local/bin/consul && \
  mkdir -p ${CONSUL_HOME} && \
  mkdir -p ${CONSUL_HOME}/data && \
  mkdir -p ${CONSUL_HOME}/config && \
  cd ${CONSUL_HOME} && \
  unzip /tmp/${CONSUL_VERSION}_web_ui.zip && \
  mv dist ui && \
  rm /tmp/${CONSUL_VERSION}_linux_amd64.zip /tmp/${CONSUL_VERSION}_web_ui.zip /tmp/${CONSUL_VERSION}_SHA256SUMS

ADD consul.json.tmpl ${CONSUL_HOME}/config/consul.json

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["consul"]
