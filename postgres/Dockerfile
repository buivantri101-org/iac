FROM postgres:16-alpine

RUN apk add --no-cache curl jq

COPY vault-entrypoint.sh /usr/local/bin/vault-entrypoint.sh
RUN chmod +x /usr/local/bin/vault-entrypoint.sh

ENTRYPOINT ["vault-entrypoint.sh"]
CMD ["postgres"]
