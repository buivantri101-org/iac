#!/bin/sh
set -eu

: "${VAULT_ADDR:?VAULT_ADDR is required}"
: "${VAULT_ROLE_ID:?VAULT_ROLE_ID is required}"
: "${VAULT_SECRET_ID:?VAULT_SECRET_ID is required}"
: "${VAULT_SECRET_PATH:?VAULT_SECRET_PATH is required}"

echo "Waiting for Vault at $VAULT_ADDR..."
until curl -sf "$VAULT_ADDR/v1/sys/health?standbyok=true" > /dev/null; do
  sleep 1
done

echo "Authenticating to Vault via AppRole..."
VAULT_TOKEN=$(curl -sf --request POST \
  --data "{\"role_id\":\"$VAULT_ROLE_ID\",\"secret_id\":\"$VAULT_SECRET_ID\"}" \
  "$VAULT_ADDR/v1/auth/approle/login" | jq -r '.auth.client_token')

if [ -z "$VAULT_TOKEN" ] || [ "$VAULT_TOKEN" = "null" ]; then
  echo "Failed to authenticate to Vault" >&2
  exit 1
fi

echo "Fetching secret from $VAULT_SECRET_PATH..."
SECRET=$(curl -sf --header "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/$VAULT_SECRET_PATH")

export GF_SECURITY_ADMIN_USER=$(echo "$SECRET" | jq -r '.data.data.admin_user')
export GF_SECURITY_ADMIN_PASSWORD=$(echo "$SECRET" | jq -r '.data.data.admin_password')

unset VAULT_ROLE_ID VAULT_SECRET_ID VAULT_TOKEN SECRET

exec /run.sh "$@"
