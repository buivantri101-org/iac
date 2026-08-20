FROM grafana/grafana:latest

USER root
RUN apk add --no-cache curl jq

COPY vault-entrypoint.sh /usr/local/bin/vault-entrypoint.sh
RUN chmod +x /usr/local/bin/vault-entrypoint.sh

USER grafana
ENTRYPOINT ["vault-entrypoint.sh"]
