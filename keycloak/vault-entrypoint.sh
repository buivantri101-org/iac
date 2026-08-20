#!/bin/sh
set -eu

: "${VAULT_ADDR:?VAULT_ADDR is required}"
: "${VAULT_ROLE_ID:?VAULT_ROLE_ID is required}"
: "${VAULT_SECRET_ID:?VAULT_SECRET_ID is required}"
: "${VAULT_SECRET_PATH:?VAULT_SECRET_PATH is required}"

export VAULT_ADDR
export HOME=/tmp

echo "Waiting for Vault to be reachable and unsealed..."
until vault status >/dev/null 2>&1; do
  sleep 1
done

echo "Authenticating to Vault via AppRole..."
LOGIN_JSON=$(vault write -format=json auth/approle/login role_id="$VAULT_ROLE_ID" secret_id="$VAULT_SECRET_ID")
VAULT_TOKEN=$(printf '%s' "$LOGIN_JSON" | sed -n 's/.*"client_token": *"\([^"]*\)".*/\1/p')

if [ -z "$VAULT_TOKEN" ]; then
  echo "Failed to authenticate to Vault" >&2
  exit 1
fi
export VAULT_TOKEN

echo "Fetching secret from $VAULT_SECRET_PATH..."
export KC_BOOTSTRAP_ADMIN_USERNAME=$(vault kv get -field=admin_user "$VAULT_SECRET_PATH")
export KC_BOOTSTRAP_ADMIN_PASSWORD=$(vault kv get -field=admin_password "$VAULT_SECRET_PATH")

unset VAULT_ROLE_ID VAULT_SECRET_ID VAULT_TOKEN LOGIN_JSON

exec /opt/keycloak/bin/kc.sh "$@"
