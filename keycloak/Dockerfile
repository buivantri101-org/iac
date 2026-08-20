FROM hashicorp/vault:latest AS vault-cli

FROM quay.io/keycloak/keycloak:latest

USER root
COPY --from=vault-cli /bin/vault /usr/local/bin/vault
COPY vault-entrypoint.sh /opt/keycloak/bin/vault-entrypoint.sh
RUN chmod +x /opt/keycloak/bin/vault-entrypoint.sh

USER 1000
ENTRYPOINT ["/opt/keycloak/bin/vault-entrypoint.sh"]
CMD ["start-dev"]
